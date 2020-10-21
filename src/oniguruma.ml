type _ encoding
type syntax_type
type _ regex
type region

exception Error of string

external initialize : unit -> unit =
  "ocaml_onig_initialize"

let () =
  Callback.register_exception "oniguruma exn" (Error "");
  initialize ()

module Encoding = struct
  type ascii
  type 'enc t = 'enc encoding

  external create_ascii : unit -> ascii t =
    "ocaml_create_onig_encoding_ascii"

  let ascii = create_ascii ()
end

type option_type =
  | OPTION_NONE
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

module SyntaxType = struct
  type t = syntax_type
  external create_oniguruma : unit -> t =
    "ocaml_create_onig_syntax_oniguruma"

  let oniguruma = create_oniguruma ()
end

external create
  : string -> option_type array -> 'enc encoding -> syntax_type
  -> ('enc regex, string) result
  = "ocaml_onig_new"

external search
  : 'enc regex -> string -> int -> int -> unit array -> region option
  = "ocaml_onig_search"
