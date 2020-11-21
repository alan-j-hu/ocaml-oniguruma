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
  type compile_time = int

  external compile_time : int -> compile_time =
    "ocaml_onig_option"

  let compile_none = compile_time 0
  let singleline = compile_time 1
  let multiline = compile_time 2
  let ignorecase = compile_time 3
  let extend = compile_time 4
  let find_longest = compile_time 5
  let find_not_empty = compile_time 6
  let negate_singleline = compile_time 7
  let dont_capture_group = compile_time 8
  let capture_group = compile_time 9
  let word_is_ascii = compile_time 10
  let digit_is_ascii = compile_time 11
  let space_is_ascii = compile_time 12
  let posix_is_ascii = compile_time 13
  let text_segment_extended_grapheme_cluster = compile_time 14
  let text_segment_word = compile_time 15

  let (<+>) = (lor)

  type search_time = int

  external search_time : int -> search_time =
    "ocaml_onig_option"

  let search_none = search_time 0
  let notbol = search_time 16
  let noteol = search_time 17

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
  : string -> Options.compile_time -> 'enc Encoding.t -> Syntax.t
  -> ('enc t, string) result
  = "ocaml_onig_new"

external search
  : 'enc t -> string -> int -> int -> Options.search_time -> Region.t option
  = "ocaml_onig_search"

external match_
  : 'enc t -> string -> int -> Options.search_time -> Region.t option
  = "ocaml_onig_match"
