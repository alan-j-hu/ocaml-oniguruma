(** Bindings to K.Kosako's {{: https://github.com/kkos/oniguruma } Oniguruma }
    library. Also see the
    {{: https://github.com/kkos/oniguruma/blob/master/doc/API } Oniguruma
    API documentation }. *)

type _ t
(** A regular expression. The phantom type parameter indicates the encoding,
    so that regular expressions for different encodings may not be mixed. *)

exception Error of string
[@ocaml.warn_on_literal_pattern]
(** The exception raised upon Oniguruma errors. *)

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
  type _ t
  (** An option. The phantom type parameter indicates whether it is
      compile-time or search-time. *)

  val (<|>) : 'a t -> 'a t -> 'a t
  (** Combines options.

      This operation is:

      - Associative: [(x <|> y) <|> z = x <|> (y <|> z)]
      - Commutative: [x <|> y = y <|> x]
      - Idempotent: [x <|> x = x] *)

  val none : _ t
  (** No options. The identity element of {!val:(<|>)}:

      - [none <|> x = x]
      - [x <|> none = x] *)

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
  val ignore_is_ascii : compile_time t
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
  val not_begin_string : search_time t
  val not_end_string : search_time t
  val not_begin_position : search_time t
end
(** Regex options. *)

module Syntax : sig
  type t
  (** The regular expression dialect. *)

  val asis : t
  val posix_basic : t
  val posix_extended : t
  val emacs : t
  val grep : t
  val gnu_regex : t
  val java : t
  val perl : t
  val perl_ng : t
  val ruby : t
  val python : t
  val oniguruma : t
  val default : unit -> t

  val set_default : t -> unit
end
(** The syntax type. *)

module Region : sig
  type t
  (** The capture groups returned by a search or match. *)

  external length : t -> int = "ocaml_onig_region_length"
  (** [length region] gets the number of captures. *)

  external capture_beg : t -> int -> int = "ocaml_onig_capture_beg"
  (** [capture_beg region idx] gets the string position of the capture at the
      index. The capture at index 0 is the entire match. The string position is
      an offset in bytes. Returns -1 if the capture group wasn't found. Raises
      {!exception:Invalid_argument} if the index is out of bounds. *)

  external capture_end : t -> int -> int = "ocaml_onig_capture_end"
  (** [capture_end region idx] gets the string position of the capture at the
      index. The capture at index 0 is the entire match. The string position is
      an offset in bytes. Returns -1 if the capture group wasn't found. Raises
      {!exception:Invalid_argument} if the index is out of bounds. *)
end
(** Match results. *)

external create
  : string -> Options.compile_time Options.t -> 'enc Encoding.t -> Syntax.t
  -> ('enc t, string) result
  = "ocaml_onig_new"
(** [create pattern options encoding syntax] creates a regex. *)

external search
  : 'enc t -> string -> int -> int -> Options.search_time Options.t
  -> Region.t option
  = "ocaml_onig_search"
(** [search regex string start range option] searches [string] within the
    substring given by indices \[start, range) for [regex]. Raises
    {!exception:Error} if there is an error (other than a negative search
    result).

    @param regex The pattern to search for
    @param string The string to search
    @param start The string position to start searching from, as a byte offset
    @param range The string position to stop searching at, as a byte offset
    @param option Search options *)

external match_
  : 'enc t -> string -> int -> Options.search_time Options.t -> Region.t option
  = "ocaml_onig_match"
(** [match_ regex string pos options] matches [string] against [regex] at
    position [pos]. Raises {!exception:Error} if there is an error (other than
    a negative match).

    @param regex The pattern to match
    @param string The string to match against
    @param pos The position of the string to match at, as a byte offset
    @param options Match options *)

module RegSet : sig
  type 'enc regex = 'enc t
  type 'enc t

  type lead =
    | POSITION_LEAD
    | REGEX_LEAD
    | PRIORITY_TO_REGEX_ORDER

  external of_list : 'enc regex list -> ('enc t, string) result =
    "ocaml_onig_regset_of_list"
  (** [of_list res] constructs a new regset from the list of regexes [res].
      After calling this function, the regexes in [res] can no longer be
      used. *)

  external number_of_regex : 'enc t -> int = "ocaml_onig_number_of_regex"

  external add : 'enc t -> 'enc regex -> unit = "ocaml_onig_regset_add"
  (** [add regset re] adds [re] to the end of the given regset. After calling
      this function, [re] can no longer be used. *)

  external replace : 'enc t -> int -> 'enc regex -> unit =
    "ocaml_onig_regset_replace"
  (** [replace regset idx re] replaces the regex [re] at index [idx] in the
      regset [regset]. After calling this function, [re] is overwritten with
      the regex formerly at index [idx] in [regset].

      Raises {!exception:Invalid_argument} if [idx] is out of bounds and
      {!exception:Error} for any other error. *)

  external remove : 'enc t -> int -> 'enc regex = "ocaml_onig_regset_remove"
  (** [remove regset idx] removes the regex at index [idx] in the regset
      [regset]. After calling this function, the indices of all subsequent
      regexes are shifted down.

      Returns the old regex.

      Raises {!exception:Invalid_argument} if [idx] is out of bounds and
      {!exception:Error} for any other error. *)

  external search
    : 'enc t -> string -> int -> int -> lead
    -> Options.search_time Options.t -> (int * Region.t) option
    = "ocaml_onig_regset_search_bytecode" "ocaml_onig_regset_search_native"
    (** [let idx, region = search regset string start range lead options]
        searches [string] within the substring given by \[start, range) and
        returns the index [idx] of the matching regex and its region [region].
        Raises {!exception:Error} if there is an error (other than a negative
        search result).

        The region [region] may outlast the lifetime of [regset].

        @param regset The regset to search use
        @param string The string to search
        @param start The string position to start searching from, as a byte
          offset
        @param range The string position to stop searching at, as a byte offset
        @param lead The lead (see {!type:lead})
        @param option Search options *)
end
(** Regsets. *)

external num_captures : _ t -> int = "ocaml_onig_num_captures"
(** The number of capture groups in the regex. The entire match itself does
    not count as a capture group. *)

external name_to_group_numbers
  : _ t -> string -> int array
  = "ocaml_onig_name_to_group_numbers"
(** [name_to_group_numbers regex name] is the group number array of [name] in
    [regex]. *)

val version : string
(** The Oniguruma version string. This is the version of the underlying C
    library, not this OCaml binding library. *)
