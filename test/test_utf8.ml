let test_search = Test_util.test_search Oniguruma.Encoding.utf8
let test_match = Test_util.test_match Oniguruma.Encoding.utf8

let () =
  test_search "a|b" "a" [0, 1];
  test_search "あ" "あ" [0, 3];
  test_search "あ*" "" [0, 0];
  test_search "あ*" "あ" [0, 3];
  test_search "あ|a" "a" [0, 1];
  test_search "あ|a" "あ" [0, 3];
  test_match "a" 3 "あa" [3, 4]
