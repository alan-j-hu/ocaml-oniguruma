type _ t

exception Error of string

external initialize : unit -> unit = "ocaml_onig_initialize"

external cleanup : unit -> unit = "ocaml_onig_end"

let () =
  Callback.register_exception
    "Oniguruma.Error" (Error "");
  Callback.register_exception
    "Oniguruma.Invalid_argument" (Invalid_argument "");
  Callback.register_exception
    "Oniguruma.Failure" (Failure "");
  initialize ();
  at_exit cleanup

module Encoding = struct
  type _ t

  type ascii
  external create_ascii : unit -> ascii t = "ocaml_create_onig_encoding_ascii"
  let ascii = create_ascii ()

  type utf8
  external create_utf8 : unit -> utf8 t = "ocaml_create_onig_encoding_utf8"
  let utf8 = create_utf8 ()
end

module Options = struct
  type _ t = int

  external option : int -> 'a t = "ocaml_onig_option"

  let (<+>) = (lor)
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
  let word_is_ascii = option 10
  let digit_is_ascii = option 11
  let space_is_ascii = option 12
  let posix_is_ascii = option 13
  let text_segment_extended_grapheme_cluster = option 14
  let text_segment_word = option 15

  type search_time

  let notbol = option 16
  let noteol = option 17
end

module Syntax = struct
  type t

  external create_asis : unit -> t =
    "ocaml_create_onig_syntax_asis"
  let asis = create_asis ()

  external create_posix_basic : unit -> t =
    "ocaml_create_onig_syntax_posix_basic"
  let posix_basic = create_posix_basic ()

  external create_posix_extended : unit -> t =
    "ocaml_create_onig_syntax_posix_extended"
  let posix_extended = create_posix_extended ()

  external create_emacs : unit -> t =
    "ocaml_create_onig_syntax_emacs"
  let emacs = create_emacs ()

  external create_grep : unit -> t =
    "ocaml_create_onig_syntax_grep"
  let grep = create_grep ()

  external create_gnu_regex : unit -> t =
    "ocaml_create_onig_syntax_gnu_regex"
  let gnu_regex = create_gnu_regex ()

  external create_java : unit -> t =
    "ocaml_create_onig_syntax_java"
  let java = create_java ()

  external create_perl : unit -> t =
    "ocaml_create_onig_syntax_perl"
  let perl = create_perl ()

  external create_perl_ng : unit -> t =
    "ocaml_create_onig_syntax_perl_ng"
  let perl_ng = create_perl_ng ()

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

external num_captures : _ t -> int = "ocaml_onig_num_captures"

external version_f : unit -> string = "ocaml_onig_version"
let version = version_f ()
