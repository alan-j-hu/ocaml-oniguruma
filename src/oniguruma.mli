type _ encoding
(** A character encoding. The phantom type parameter represents the encoding.
 *)

type syntax_type
(** The regular expression dialect. *)

type _ regex
(** A regular expression. The phantom type parameter represents the encoding,
    so that regular expressions for different encodings may not be mixed. *)

type region
(** The regions returned by a search or match. *)

exception Error of string

module Encoding : sig
  type ascii
  (** A phantom type representing ASCII. *)

  type utf8
  (** A phantom type representing UTF-8. *)

  type 'enc t = 'enc encoding
  (** A character encoding, indexed by a phantom type parameter. *)

  val ascii : ascii t
  (** The ASCII encoding. *)

  val utf8 : utf8 t
  (** The UTF-8 encoding. *)
end
(** Character encodings. *)

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

(** Compile-time options. *)

type icoption
(** Internal representation of compile-time options. *)

external coptions : coption array -> icoption = "ocaml_onig_coptions"
(** Convert the compile-time options to their internal representation. *)

type roption =
  | OPTION_NOT_BEGIN_STRING
  | OPTION_NOT_END_STRING

(** Runtime options. *)

type iroption
(** Internal representation of runtime options. *)

external roptions : roption array -> iroption = "ocaml_onig_roptions"
(** Convert the runtime options to their internal representation. *)

module SyntaxType : sig
  type t = syntax_type

  val oniguruma : t
end
(** The syntax type. *)

external create
  : string -> icoption -> 'enc encoding -> syntax_type
  -> ('enc regex, string) result
  = "ocaml_onig_new"
(** [create pattern options encoding syntax] creates a regex. *)

external search
  : 'enc regex -> string -> int -> int -> iroption -> region option
  = "ocaml_onig_search"
(** [search regex string start range option] searches
    [String.sub string start range] for [regex].

    @param regex The pattern to search for
    @param string The string to search
    @param start The string position to start searching from, as a byte offset
    @param range The string position to stop searching at, as a byte offset
    @param option Search options *)

external match_
  : 'enc regex -> string -> int -> iroption -> region option
  = "ocaml_onig_match"
(** [match_ regex string pos options] matches [regex] against [string] at
    position [pos].

    @param regex The pattern to match
    @param string The string to match against
    @param pos The position of the string to match at, as a byte offset
    @param options Match options *)

external num_regs : region -> int = "ocaml_onig_num_regs"
(** [num_regs region] gets the number of regions. *)

external get_beg : region -> int -> int = "ocaml_onig_get_beg"
(** [get_beg region idx] gets the string position of the region at the given
    index. The string position is an offset in bytes. *)

external get_end : region -> int -> int = "ocaml_onig_get_end"
(** [get_end region idx] gets the string position of the region at the given
    index. The string position is an offset in bytes. *)
