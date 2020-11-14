type _ encoding
type syntax_type
type _ regex
type region

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
  type 'enc t = 'enc encoding

  external create_ascii : unit -> ascii t =
    "ocaml_create_onig_encoding_ascii"

  external create_utf8 : unit -> utf8 t =
    "ocaml_create_onig_encoding_utf8"

  let ascii = create_ascii ()
  let utf8 = create_utf8 ()
end

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

module SyntaxType = struct
  type t = syntax_type
  external create_oniguruma : unit -> t =
    "ocaml_create_onig_syntax_oniguruma"

  let oniguruma = create_oniguruma ()
end

external create
  : string -> icoption -> 'enc encoding -> syntax_type
  -> ('enc regex, string) result
  = "ocaml_onig_new"

external search
  : 'enc regex -> string -> int -> int -> iroption -> region option
  = "ocaml_onig_search"

external match_
  : 'enc regex -> string -> int -> iroption -> region option
  = "ocaml_onig_match"

external num_regs : region -> int = "ocaml_onig_num_regs"

external reg_beg : region -> int -> int = "ocaml_onig_reg_beg"

external reg_end : region -> int -> int = "ocaml_onig_reg_end"
