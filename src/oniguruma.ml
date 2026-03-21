type _ t

exception Error of string

external initialize : unit -> unit = "ocaml_onig_initialize"

external cleanup : unit -> unit = "ocaml_onig_end"

let () =
  Callback.register_exception "Oniguruma.Error" (Error "");
  Callback.register_exception
    "Oniguruma.Invalid_argument" (Invalid_argument "");
  Callback.register_exception "Oniguruma.Failure" (Failure "");
  initialize ();
  at_exit cleanup

module Encoding = struct
  type _ t

  type ascii
  external get_ascii : unit -> ascii t = "ocaml_get_onig_encoding_ascii"
  let ascii = get_ascii ()

  type utf8
  external get_utf8 : unit -> utf8 t = "ocaml_get_onig_encoding_utf8"
  let utf8 = get_utf8 ()
end

module Options = struct
  type _ t = int

  external option : int -> 'a t = "ocaml_onig_option"

  let (<|>) = (lor)
  let none = option 0

  type compile_time

  let singleline = option 1
  let multiline = option 2
  let ignorecase = option 3
  let extend = option 4
  let find_longest = option 5
  let find_not_empty = option 6
  let negate_singleline = option 7
  let dont_capture_group = option 8
  let capture_group = option 9
  let ignore_is_ascii = option 10
  let word_is_ascii = option 11
  let digit_is_ascii = option 12
  let space_is_ascii = option 13
  let posix_is_ascii = option 14
  let text_segment_extended_grapheme_cluster = option 15
  let text_segment_word = option 16

  type search_time

  let notbol = option 101
  let noteol = option 102
  let not_begin_string = option 103
  let not_end_string = option 104
  let not_begin_position = option 105
end

module Syntax = struct
  type t

  external get_asis : unit -> t = "ocaml_get_onig_syntax_asis"
  let asis = get_asis ()

  external get_posix_basic : unit -> t = "ocaml_get_onig_syntax_posix_basic"
  let posix_basic = get_posix_basic ()

  external get_posix_extended : unit -> t =
    "ocaml_get_onig_syntax_posix_extended"
  let posix_extended = get_posix_extended ()

  external get_emacs : unit -> t = "ocaml_get_onig_syntax_emacs"
  let emacs = get_emacs ()

  external get_grep : unit -> t = "ocaml_get_onig_syntax_grep"
  let grep = get_grep ()

  external get_gnu_regex : unit -> t = "ocaml_get_onig_syntax_gnu_regex"
  let gnu_regex = get_gnu_regex ()

  external get_java : unit -> t = "ocaml_get_onig_syntax_java"
  let java = get_java ()

  external get_perl : unit -> t = "ocaml_get_onig_syntax_perl"
  let perl = get_perl ()

  external get_perl_ng : unit -> t = "ocaml_get_onig_syntax_perl_ng"
  let perl_ng = get_perl_ng ()

  external get_ruby : unit -> t = "ocaml_get_onig_syntax_ruby"
  let ruby = get_ruby ()

  external get_python : unit -> t = "ocaml_get_onig_syntax_python"
  let python = get_python ()

  external get_oniguruma : unit -> t = "ocaml_get_onig_syntax_oniguruma"
  let oniguruma = get_oniguruma ()

  external default : unit -> t = "ocaml_get_onig_syntax_default"

  external set_default : t -> unit = "ocaml_onig_set_default_syntax"
end

module Region = struct
  type t

  external length : t -> int = "ocaml_onig_region_length"

  external capture_beg : t -> int -> int = "ocaml_onig_capture_beg"

  external capture_end : t -> int -> int = "ocaml_onig_capture_end"
end

external create
  : string -> Options.compile_time Options.t -> 'enc Encoding.t -> Syntax.t
  -> ('enc t, string) result
  = "ocaml_onig_new"

external search
  : 'enc t -> string -> int -> int -> Options.search_time Options.t
  -> Region.t option
  = "ocaml_onig_search"

external match_
  : 'enc t -> string -> int -> Options.search_time Options.t -> Region.t option
  = "ocaml_onig_match"

module RegSet = struct
  type 'a regex = 'a t
  type _ t

  type lead =
    | POSITION_LEAD
    | REGEX_LEAD
    | PRIORITY_TO_REGEX_ORDER

  external of_list : 'enc regex list -> ('enc t, string) result =
    "ocaml_onig_regset_of_list"

  external number_of_regex : 'enc t -> int = "ocaml_onig_number_of_regex"

  external add : 'enc t -> 'enc regex -> unit = "ocaml_onig_regset_add"

  external replace : 'enc t -> int -> 'enc regex -> unit =
    "ocaml_onig_regset_replace"

  external remove : 'enc t -> int -> 'enc regex = "ocaml_onig_regset_remove"

  external search
    : 'enc t -> string -> int -> int -> lead
    -> Options.search_time Options.t -> (int * Region.t) option
    = "ocaml_onig_regset_search_bytecode" "ocaml_onig_regset_search_native"
end

external num_captures : _ t -> int = "ocaml_onig_num_captures"

external name_to_group_numbers
  : _ t -> string -> int array
  = "ocaml_onig_name_to_group_numbers"

external version_f : unit -> string = "ocaml_onig_version"
let version = version_f ()
