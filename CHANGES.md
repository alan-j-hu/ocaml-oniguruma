# 0.2.0 (March 22, 2026)

- [Breaking Change] Change option composition operator from `<+>` to `<|>`.
- [Breaking Change] Change type signature of `Syntax.default` from `Syntax.t`
  to `unit -> Syntax.t`.
- Add function `Syntax.set_default`.
- Add `ruby`, `python`, and `oniguruma` syntaxes.
- Add compile-time options `ignore_is_ascii`, `word_is_ascii`,
  `digit_is_ascii`, `space_is_ascii`, `posix_is_ascii`,
  `text_segment_extended_grapheme_cluster`, and `text_segment_word`.
- Add search-time options `not_begin_string`, `not_end_string`, and
  `not_begin_position` (See also PR (#2) contributed by @davesnx).
- Add bindings to RegSet API.

# 0.1.2 (October 27, 2022)

- Add `name_to_group_numbers`.
- Use direct field assignment to initialize blocks allocated with
  `caml_alloc_small`.

# 0.1.1 (September 6, 2021)

- Use pkg-config to determine C flags (fixes #1).
- Explicitly cast between `const char*` and `const UChar*`.

# 0.1.0 (November 23, 2020)

Initial release.
