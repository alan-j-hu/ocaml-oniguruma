type _ t

exception Error of string

external initialize : unit -> unit = "ocaml_onig_initialize"

external cleanup : unit -> unit = "ocaml_onig_end"

let () =
  Callback.register_exception "oniguruma exn" (Error "");
  initialize ();
  at_exit cleanup

module Encoding = struct
  type ascii
  type utf8
  type _ t

  external create_ascii : unit -> ascii t =
    "ocaml_create_onig_encoding_ascii"

  external create_utf8 : unit -> utf8 t =
    "ocaml_create_onig_encoding_utf8"

  let ascii = create_ascii ()
  let utf8 = create_utf8 ()
end

module Options = struct
  type compile_options = int

  external compile_option : int -> compile_options =
    "ocaml_onig_option"

  let compile_none = compile_option 0
  let singleline = compile_option 1
  let multiline = compile_option 2
  let ignorecase = compile_option 3
  let extend = compile_option 4
  let find_longest = compile_option 5
  let find_not_empty = compile_option 6
  let negate_singleline = compile_option 7
  let dont_capture_group = compile_option 8
  let capture_group = compile_option 9
  let word_is_ascii = compile_option 10
  let digit_is_ascii = compile_option 11
  let space_is_ascii = compile_option 12
  let posix_is_ascii = compile_option 13
  let text_segment_extended_grapheme_cluster = compile_option 14
  let text_segment_word = compile_option 15

  let (<+>) = (lor)

  type search_options = int

  external search_option : int -> search_options =
    "ocaml_onig_option"

  let search_none = search_option 0
  let not_begin_string = search_option 16
  let not_end_string = search_option 17

  let (<|>) = (lor)
end

module Syntax = struct
  type t

  external create_oniguruma : unit -> t =
    "ocaml_create_onig_syntax_oniguruma"

  let oniguruma = create_oniguruma ()
end

module Region = struct
  type t

  external length : t -> int = "ocaml_onig_region_length"

  external capture_beg : t -> int -> int = "ocaml_onig_capture_beg"

  external capture_end : t -> int -> int = "ocaml_onig_capture_end"
end

external create
  : string -> Options.compile_options -> 'enc Encoding.t -> Syntax.t
  -> ('enc t, string) result
  = "ocaml_onig_new"

external search
  : 'enc t -> string -> int -> int -> Options.search_options -> Region.t option
  = "ocaml_onig_search"

external match_
  : 'enc t -> string -> int -> Options.search_options -> Region.t option
  = "ocaml_onig_match"
