#define CAML_NAME_SPACE
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <oniguruma.h>

#define Regex_val(v) (*((regex_t **) Data_custom_val(v)))
#define Region_val(v) (*((OnigRegion **) Data_custom_val(v)))

static const value* ocaml_onig_Error_exn = NULL;

CAMLprim value ocaml_onig_initialize(value unit)
{
    CAMLparam1(unit);
    ocaml_onig_Error_exn = caml_named_value("oniguruma exn");
    OnigEncoding use_encodings[] = {
        ONIG_ENCODING_ASCII,
        ONIG_ENCODING_ISO_8859_1,
        ONIG_ENCODING_ISO_8859_2,
        ONIG_ENCODING_ISO_8859_3,
        ONIG_ENCODING_ISO_8859_4,
        ONIG_ENCODING_ISO_8859_5,
        ONIG_ENCODING_ISO_8859_6,
        ONIG_ENCODING_ISO_8859_7,
        ONIG_ENCODING_ISO_8859_8,
        ONIG_ENCODING_ISO_8859_9,
        ONIG_ENCODING_ISO_8859_10,
        ONIG_ENCODING_ISO_8859_11,
        ONIG_ENCODING_ISO_8859_13,
        ONIG_ENCODING_ISO_8859_14,
        ONIG_ENCODING_ISO_8859_15,
        ONIG_ENCODING_ISO_8859_16,
        ONIG_ENCODING_UTF8,
        ONIG_ENCODING_UTF16_BE,
        ONIG_ENCODING_UTF16_LE,
        ONIG_ENCODING_UTF32_BE,
        ONIG_ENCODING_UTF32_LE,
        ONIG_ENCODING_EUC_JP,
        ONIG_ENCODING_EUC_TW,
        ONIG_ENCODING_EUC_KR,
        ONIG_ENCODING_EUC_CN,
        ONIG_ENCODING_SJIS,
        ONIG_ENCODING_KOI8_R,
        ONIG_ENCODING_CP1251,
        ONIG_ENCODING_BIG5,
        ONIG_ENCODING_GB18030
    };
    onig_initialize(
        use_encodings, sizeof(use_encodings) / sizeof(use_encodings[0]));
    CAMLreturn(Val_unit);
}

CAMLprim value ocaml_create_onig_encoding_ascii(value unit)
{
    CAMLparam1(unit);
    CAMLlocal1(v);
    v = caml_alloc_small(1, Abstract_tag);
    Store_field(v, 0, (value) ONIG_ENCODING_ASCII);
    CAMLreturn(v);
}

CAMLprim value ocaml_create_onig_syntax_oniguruma(value unit)
{
    CAMLparam1(unit);
    CAMLlocal1(v);
    v = caml_alloc_small(1, Abstract_tag);
    Store_field(v, 0, (value) ONIG_SYNTAX_ONIGURUMA);
    CAMLreturn(v);
}

static void finalize_regex_t(value v)
{
    onig_free(Regex_val(v));
}

static struct custom_operations regex_ops = {
    .identifier = "ocaml.oniguruma.regex_t",
    .finalize = finalize_regex_t,
    .compare = custom_compare_default,
    .compare_ext = custom_compare_ext_default,
    .hash = custom_hash_default,
    .serialize = custom_serialize_default,
    .deserialize = custom_deserialize_default,
    .fixed_length = custom_fixed_length_default
};

OnigOptionType option_type(value v)
{
    switch(Int_val(v)) {
    case 0: return ONIG_OPTION_NONE;
    case 1: return ONIG_OPTION_SINGLELINE;
    case 2: return ONIG_OPTION_MULTILINE;
    case 3: return ONIG_OPTION_IGNORECASE;
    case 4: return ONIG_OPTION_EXTEND;
    case 5: return ONIG_OPTION_FIND_LONGEST;
    case 6: return ONIG_OPTION_FIND_NOT_EMPTY;
    case 7: return ONIG_OPTION_NEGATE_SINGLELINE;
    case 8: return ONIG_OPTION_DONT_CAPTURE_GROUP;
    case 9: return ONIG_OPTION_CAPTURE_GROUP;
    case 10: return ONIG_OPTION_WORD_IS_ASCII;
    case 11: return ONIG_OPTION_DIGIT_IS_ASCII;
    case 12: return ONIG_OPTION_SPACE_IS_ASCII;
    case 13: return ONIG_OPTION_POSIX_IS_ASCII;
    case 14: return ONIG_OPTION_TEXT_SEGMENT_EXTENDED_GRAPHEME_CLUSTER;
    case 15: return ONIG_OPTION_TEXT_SEGMENT_WORD;
    }
}

CAMLprim value ocaml_onig_new(
    value pattern_val,
    value array_val,
    value enc,
    value syntax)
{
    CAMLparam4(pattern_val, array_val, enc, syntax);
    CAMLlocal3(regex_val, error, result);

    regex_t* regex;
    const UChar* pattern = String_val(pattern_val);
    const uintnat pattern_length = caml_string_length(pattern_val);

    OnigOptionType option = 0;
    int flag_count = Wosize_val(array_val);
    for(int i = 0; i < flag_count; ++i) {
        const value elem = Field(array_val, i);
        const OnigOptionType flag = option_type(elem);
        option |= flag;
    }

    OnigErrorInfo err_info;
    const int err_code = onig_new(
        &regex,
        pattern,
        pattern + pattern_length,
        option,
        *((OnigEncoding*) Data_abstract_val(enc)),
        *((OnigSyntaxType**) Data_abstract_val(syntax)),
        &err_info);
    if(err_code != ONIG_NORMAL) {
        UChar err_buf[ONIG_MAX_ERROR_MESSAGE_LEN];
        int error_length = onig_error_code_to_str(
            err_buf, err_code, &err_info);
        error = caml_copy_string(err_buf);
        /* Must store all fields immediately after small allocation! */
        result = caml_alloc_small(1, 1);
        Store_field(result, 0, error);
        CAMLreturn(result);
    }
    regex_val = caml_alloc_custom(&regex_ops, sizeof(regex_t*), 0, 1);
    Regex_val(regex_val) = regex;
    /* Must store all fields immediately after small allocation! */
    result = caml_alloc_small(1, 0);
    Store_field(result, 0, regex_val);
    CAMLreturn(result);
}

static void finalize_region(value v)
{
    onig_region_free(Region_val(v), 1);
}

static struct custom_operations region_ops = {
    .identifier = "ocaml.oniguruma.region",
    .finalize = finalize_region,
    .compare = custom_compare_default,
    .compare_ext = custom_compare_ext_default,
    .hash = custom_hash_default,
    .serialize = custom_serialize_default,
    .deserialize = custom_deserialize_default,
    .fixed_length = custom_fixed_length_default
};

CAMLprim value ocaml_onig_search(
    value regex_val,
    value string_val,
    value search_start_val,
    value search_end_val,
    value options_val)
{
    CAMLparam5(
        regex_val, string_val, search_start_val, search_end_val, options_val);
    CAMLlocal2(region_val, option_val);

    regex_t* reg = Regex_val(regex_val);
    const UChar* string = String_val(string_val);
    const uintnat string_length = caml_string_length(string_val);
    const int search_start = Int_val(search_start_val);
    const int search_end = Int_val(search_end_val);

    int option = ONIG_OPTION_CAPTURE_GROUP;

    OnigRegion* region = onig_region_new();
    region_val = caml_alloc_custom(&region_ops, sizeof(OnigRegion*), 0, 1);
    Region_val(region_val) = region;
    int ret = onig_search(
        reg,
        string,
        string + string_length,
        string + search_start,
        string + search_end,
        region,
        option);
    if(ret >= 0) {
        /* option_val : region option */
        /* Must store all fields immediately after small allocation! */
        option_val = caml_alloc_small(1, 0);
        Store_field(option_val, 0, region_val);
        CAMLreturn(option_val);
    }
    if(ret == ONIG_MISMATCH) {
        CAMLreturn(Val_int(0));
    }
    UChar err_buf[ONIG_MAX_ERROR_MESSAGE_LEN];
    onig_error_code_to_str(err_buf, ret);
    caml_raise_with_string(*ocaml_onig_Error_exn, err_buf);
}