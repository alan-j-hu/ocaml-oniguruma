(** Bindings to K.Kosako's {{: https://github.com/kkos/oniguruma } Oniguruma }
    library. Also see the
    {{: https://github.com/kkos/oniguruma/blob/master/doc/API } Oniguruma
    API documentation }. *)

type _ t
(** A regular expression. The phantom type parameter indicates the encoding,
    so that regular expressions for different encodings may not be mixed. *)

exception Error of string
[@warn_on_literal_pattern]

module Encoding : sig
  type _ t
  (** A character encoding. The phantom type parameter indicates the
      encoding. *)

  type ascii
  val ascii : ascii t
  (** The ASCII encoding. *)

  type utf8
  val utf8 : utf8 t
  (** The UTF-8 encoding. *)
end
(** Character encodings. *)

module Options : sig
  (** Manipulation of regex options. *)

  type _ t
  (** An option. The phantom type parameter indicates whether it is
      compile-time or search-time. *)

  val (<+>) : 'a t -> 'a t -> 'a t
  (** Combines options. *)

  val none : _ t
  (** No options. The neutral element of {!val:(<+>)}. *)

  type compile_time
  (** Represents compile-time options. *)

  val singleline : compile_time t
  val multiline : compile_time t
  val ignorecase : compile_time t
  val extend : compile_time t
  val find_longest : compile_time t
  val find_not_empty : compile_time t
  val negate_singleline : compile_time t
  val dont_capture_group : compile_time t
  val capture_group : compile_time t
  val word_is_ascii : compile_time t
  val digit_is_ascii : compile_time t
  val space_is_ascii : compile_time t
  val posix_is_ascii : compile_time t
  val text_segment_extended_grapheme_cluster : compile_time t
  val text_segment_word : compile_time t

  type search_time
  (** Represents search-time options. *)

  val notbol : search_time t
  val noteol : search_time t
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
  (** [length region] gets the number of captures. *)

  external capture_beg : t -> int -> int = "ocaml_onig_capture_beg"
  (** [capture_beg region idx] gets the string position of the capture group at
      the index. The string position is an offset in bytes. Returns -1 if the
      capture group wasn't found. Raises {!exception:Error} if the index is
      out of bounds. *)

  external capture_end : t -> int -> int = "ocaml_onig_capture_end"
  (** [capture_end region idx] gets the string position of the capture group at
      the index. The string position is an offset in bytes. Returns -1 if the
      capture group wasn't found. Raises {!exception:Error} if the index is
      out of bounds. *)
end

external create
  : string -> Options.compile_time Options.t -> 'enc Encoding.t -> Syntax.t
  -> ('enc t, string) result
  = "ocaml_onig_new"
(** [create pattern options encoding syntax] creates a regex. *)

external search
  : 'enc t -> string -> int -> int -> Options.search_time Options.t
  -> Region.t option
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
  : 'enc t -> string -> int -> Options.search_time Options.t -> Region.t option
  = "ocaml_onig_match"
(** [match_ regex string pos options] matches [regex] against [string] at
    position [pos]. Raises {!exception:Error} if there is an error (other than
    a mismatch).

    @param regex The pattern to match
    @param string The string to match against
    @param pos The position of the string to match at, as a byte offset
    @param options Match options *)
