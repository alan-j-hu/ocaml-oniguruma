let test_search_ascii coptions soptions =
  Test_util.test_search coptions soptions Oniguruma.Encoding.ascii
let neg_test_search_ascii coptions soptions =
  Test_util.neg_test_search coptions soptions Oniguruma.Encoding.ascii
let test_search_utf8 coptions soptions =
  Test_util.test_search coptions soptions Oniguruma.Encoding.utf8
let neg_test_search_utf8 coptions soptions =
  Test_util.neg_test_search coptions soptions Oniguruma.Encoding.utf8
let test_match_ascii coptions soptions =
  Test_util.test_match coptions soptions Oniguruma.Encoding.ascii
let neg_test_match_ascii coptions soptions =
  Test_util.neg_test_match coptions soptions Oniguruma.Encoding.ascii
let test_match_utf8 coptions soptions =
  Test_util.test_match coptions soptions Oniguruma.Encoding.utf8
let neg_test_match_utf8 coptions soptions =
  Test_util.neg_test_match coptions soptions Oniguruma.Encoding.utf8

let () =
  let open Oniguruma.Options in
  test_search_ascii multiline none "." "\n" [0, 1];
  neg_test_search_ascii none none "." "\n";

  test_search_ascii ignorecase none "a" "A" [0, 1];
  neg_test_search_ascii none none "a" "A";
  test_search_ascii ignorecase none "A" "a" [0, 1];

  neg_test_search_ascii (none <|> none) none "ML" "OCaml";
  test_search_ascii ignorecase none "ML" "OCaml" [3, 5];
  test_search_ascii ignorecase none "ml" "OCaml" [3, 5];
  test_search_ascii (none <|> ignorecase) none "ML" "SML" [1, 3];
  test_search_ascii (ignorecase <|> none) none "ml" "SML" [1, 3];
  test_search_utf8 ignorecase none "λ" "Λ" [0, 2];
  test_search_utf8 ignorecase none "Λ" "λx.x" [0, 2];

  neg_test_search_ascii none none "A" "a";
  test_search_utf8 ignorecase none "a" "A" [0, 1];
  neg_test_search_utf8 none none "a" "A";
  test_search_utf8 ignorecase none "A" "a" [0, 1];
  neg_test_search_utf8 none none "A" "a";

  test_search_utf8 (ignorecase <|> ignore_is_ascii) none "A" "a" [0, 1];
  test_search_utf8 (ignorecase <|> ignore_is_ascii) none "a" "A" [0, 1];
  neg_test_search_utf8 (ignorecase <|> ignore_is_ascii) none "λ" "Λ";
  neg_test_search_utf8 (ignorecase <|> ignore_is_ascii) none "Λ" "λx.x";

  test_match_utf8 none none "\\d" 0 "\u{0660}" [0, 2];
  neg_test_match_utf8 digit_is_ascii none "\\d" 0 "\u{0660}";

  test_match_utf8 none none "\\s" 0 "\u{2000}" [0, 3];
  neg_test_match_utf8 space_is_ascii none "\\s" 0 "\u{2000}";

  test_match_utf8 posix_is_ascii none "\\d" 0 "2" [0, 1];
  test_match_utf8 posix_is_ascii none "\\s" 0 " " [0, 1];
  neg_test_match_utf8 posix_is_ascii none "\\d" 0 " ";
  neg_test_match_utf8 posix_is_ascii none "\\s" 0 "2";
  neg_test_match_utf8 posix_is_ascii none "\\d" 0 "\u{0660}";
  neg_test_match_utf8 posix_is_ascii none "\\s" 0 "\u{2000}";

  test_match_utf8 text_segment_word none "\\X" 0 "3.2 4.5" [0, 3];
  test_match_utf8 text_segment_extended_grapheme_cluster none
    "\\X" 0 "3.2 4.5" [0, 1];

  test_match_ascii none none "^" 0 "" [0, 0];
  test_match_ascii none (none <|> none) "^" 0 "" [0, 0];
  neg_test_match_ascii none none "^" 1 "a";
  neg_test_match_ascii none notbol "^" 0 "";
  test_match_ascii none noteol "^" 0 "" [0, 0];
  neg_test_match_ascii none (notbol <|> noteol) "^" 0 "";
  neg_test_match_ascii none (none <|> noteol <|> notbol) "^" 0 "";

  test_match_ascii none none "$" 0 "" [0, 0];
  test_match_ascii none notbol "$" 0 "" [0, 0];
  neg_test_match_ascii none noteol "$" 0 "";
  neg_test_match_ascii none (notbol <|> noteol) "$" 0 "";
  neg_test_match_ascii none (noteol <|> notbol) "$" 0 "";

  test_match_ascii none none "$" 1 "a" [1, 1];
  neg_test_match_ascii none noteol "$" 1 "a";
  neg_test_match_ascii none (notbol <|> noteol) "$" 1 "a";
  neg_test_match_ascii none (noteol <|> notbol) "$" 1 "a";

  test_match_ascii none none "^$" 0 "" [0, 0];
  neg_test_match_ascii none (notbol <|> noteol) "^$" 0 "";

  test_match_ascii none none "^a$" 0 "a" [0, 1];
  neg_test_match_ascii none notbol "^a$" 0 "a";
  neg_test_match_ascii none noteol "^a$" 0 "a";
  neg_test_match_ascii none (notbol <|> noteol) "^a$" 0 "a";
  neg_test_match_ascii none (noteol <|> notbol) "^a$" 0 "a";

  test_match_ascii none none "\\Aab" 0 "ab" [0, 2];
  neg_test_match_ascii none not_begin_string "\\Aab" 0 "ab";

  test_match_ascii none none "ab\\Z" 0 "ab" [0, 2];
  neg_test_match_ascii none not_end_string "ab\\Z" 0 "ab";

  test_match_ascii none none "\\Aab\\Z" 0 "ab" [0, 2];
  neg_test_match_ascii none (not_begin_string <|> not_end_string)
    "\\Aab\\Z" 0 "ab";

  test_match_ascii none none "\\GA" 1 "(AB)" [1, 2];
  neg_test_match_ascii none not_begin_position "\\Gab" 1 "(AB)"
