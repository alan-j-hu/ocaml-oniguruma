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

module Option = struct
  type coption =
    | SINGLELINE
    | MULTILINE
    | IGNORECASE
    | EXTEND
    | FIND_LONGEST
    | FIND_NOT_EMPTY
    | NEGATE_SINGLELINE
    | DONT_CAPTURE_GROUP
    | CAPTURE_GROUP
    | WORD_IS_ASCII
    | DIGIT_IS_ASCII
    | SPACE_IS_ASCII
    | POSIX_IS_ASCII
    | TEXT_SEGMENT_EXTENDED_GRAPHEME_CLUSTER
    | TEXT_SEGMENT_WORD

  type icoption

  external coptions : coption array -> icoption = "ocaml_onig_coptions"

  type roption =
    | NOT_BEGIN_STRING
    | NOT_END_STRING

  type iroption

  external roptions : roption array -> iroption = "ocaml_onig_roptions"
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

  external reg_beg : t -> int -> int = "ocaml_onig_reg_beg"

  external reg_end : t -> int -> int = "ocaml_onig_reg_end"
end

external create
  : string -> Option.icoption -> 'enc Encoding.t -> Syntax.t
  -> ('enc t, string) result
  = "ocaml_onig_new"

external search
  : 'enc t -> string -> int -> int -> Option.iroption -> Region.t option
  = "ocaml_onig_search"

external match_
  : 'enc t -> string -> int -> Option.iroption -> Region.t option
  = "ocaml_onig_match"
