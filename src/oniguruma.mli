(** Bindings to K.Kosako's {{: https://github.com/kkos/oniguruma } Oniguruma }
    library. *)

type _ t
(** A regular expression. The phantom type parameter represents the encoding,
    so that regular expressions for different encodings may not be mixed. *)

exception Error of string

module Encoding : sig
  type ascii
  (** A phantom type representing ASCII. *)

  type utf8
  (** A phantom type representing UTF-8. *)

  type _ t
  (** A character encoding, indexed by a phantom type parameter. *)

  val ascii : ascii t
  (** The ASCII encoding. *)

  val utf8 : utf8 t
  (** The UTF-8 encoding. *)
end
(** Character encodings. *)

module Option : sig
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

  (** Compile-time options. *)

  type icoption
  (** Internal representation of compile-time options. *)

  external coptions : coption array -> icoption = "ocaml_onig_coptions"
  (** Convert the compile-time options to their internal representation. *)

  type roption =
    | NOT_BEGIN_STRING
    | NOT_END_STRING

  (** Runtime options. *)

  type iroption
  (** Internal representation of runtime options. *)

  external roptions : roption array -> iroption = "ocaml_onig_roptions"
  (** Convert the runtime options to their internal representation. *)
end

module Syntax : sig
  type t
  (** The regular expression dialect. *)

  val oniguruma : t
end
(** The syntax type. *)

module Region : sig
  type t
  (** The capture groups returned by a search or match. *)

  external length : t -> int = "ocaml_onig_region_length"
  (** [length region] gets the number of regions. *)

  external cap_beg : t -> int -> int = "ocaml_onig_cap_beg"
  (** [cap_beg region idx] gets the string position of the capture group at the
      index. The string position is an offset in bytes. Returns -1 if the
      capture group wasn't found. Raises {!exception:Error} if the index is
      out of bounds. *)

  external cap_end : t -> int -> int = "ocaml_onig_cap_end"
  (** [cap_end region idx] gets the string position of the capture group at the
      index. The string position is an offset in bytes. Returns -1 if the
      capture group wasn't found. Raises {!exception:Error} if the index is
      out of bounds. *)
end

external create
  : string -> Option.icoption -> 'enc Encoding.t -> Syntax.t
  -> ('enc t, string) result
  = "ocaml_onig_new"
(** [create pattern options encoding syntax] creates a regex. *)

external search
  : 'enc t -> string -> int -> int -> Option.iroption -> Region.t option
  = "ocaml_onig_search"
(** [search regex string start range option] searches
    [String.sub string start range] for [regex]. Raises {!exception:Error} if
    there is an error (other than a mismatch).

    @param regex The pattern to search for
    @param string The string to search
    @param start The string position to start searching from, as a byte offset
    @param range The string position to stop searching at, as a byte offset
    @param option Search options *)

external match_
  : 'enc t -> string -> int -> Option.iroption -> Region.t option
  = "ocaml_onig_match"
(** [match_ regex string pos options] matches [regex] against [string] at
    position [pos]. Raises {!exception:Error} if there is an error (other than
    a mismatch).

    @param regex The pattern to match
    @param string The string to match against
    @param pos The position of the string to match at, as a byte offset
    @param options Match options *)
