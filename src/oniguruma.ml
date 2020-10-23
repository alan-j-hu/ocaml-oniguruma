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
  | OPTION_SINGLELINE
  | OPTION_MULTILINE
  | OPTION_IGNORECASE
  | OPTION_EXTEND
  | OPTION_FIND_LONGEST
  | OPTION_FIND_NOT_EMPTY
  | OPTION_NEGATE_SINGLELINE
  | OPTION_DONT_CAPTURE_GROUP
  | OPTION_CAPTURE_GROUP
  | OPTION_WORD_IS_ASCII
  | OPTION_DIGIT_IS_ASCII
  | OPTION_SPACE_IS_ASCII
  | OPTION_POSIX_IS_ASCII
  | OPTION_TEXT_SEGMENT_EXTENDED_GRAPHEME_CLUSTER
  | OPTION_TEXT_SEGMENT_WORD

type icoption

external coptions : coption array -> icoption = "ocaml_onig_coptions"

type roption =
  | OPTION_NOT_BEGIN_STRING
  | OPTION_NOT_END_STRING

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

external num_regs : region -> int = "ocaml_onig_num_regs"

(** The string position is always returned in byte offsets. *)
external get_beg : region -> int -> int = "ocaml_onig_get_beg"

(** The string position is always returned in byte offsets. *)
external get_end : region -> int -> int = "ocaml_onig_get_end"
