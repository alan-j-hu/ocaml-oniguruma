let test_search =
  Test_util.test_search [||] [||] Oniguruma.Encoding.utf8
let neg_test_search =
  Test_util.neg_test_search [||] [||] Oniguruma.Encoding.utf8
let test_search_out_of_bounds =
  Test_util.test_search_out_of_bounds [||] [||] Oniguruma.Encoding.utf8
let test_match =
  Test_util.test_match [||] [||] Oniguruma.Encoding.utf8
let neg_test_match =
  Test_util.neg_test_match [||] [||] Oniguruma.Encoding.utf8
let test_match_out_of_bounds =
  Test_util.test_match_out_of_bounds [||] [||] Oniguruma.Encoding.utf8

let () =
  test_search "a|b" "a" [0, 1];
  test_search "あ" "あ" [0, 3];
  test_search "あ*" "" [0, 0];
  test_search "あ*" "あ" [0, 3];
  test_search "あ|a" "a" [0, 1];
  test_search "あ|a" "あ" [0, 3];
  neg_test_search "あ" "a";
  neg_test_search "a" "あ";
  test_match "a" 3 "あa" [3, 4];
  test_match "い" 3 "あいう" [3, 6];
  neg_test_match "a" 1 "あa";
  test_search_out_of_bounds "a" "a" 1 2;
  test_search_out_of_bounds "a" "a" (-1) 1
