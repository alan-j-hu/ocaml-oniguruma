let test_search = Test_util.test_search Oniguruma.Encoding.ascii
let test_match = Test_util.test_match Oniguruma.Encoding.ascii

let () =
  test_search "a|b" "a" [0, 1];
  test_search "a|b" "b" [0, 1];
  test_search "a(a|b)" "aa" [0, 2; 1, 2];
  test_search "a(a|b)" "ab" [0, 2; 1, 2];
  test_search "a*" "" [0, 0];
  test_search "a*" "a" [0, 1];
  test_search "a*" "aa" [0, 2];
  test_search "a*" "aaa" [0, 3];
  test_search "a*b" "b" [0, 1];
  test_search "a*b" "ab" [0, 2];
  test_search "a*b" "aab" [0, 3];
  test_search "a(a*b)b" "aaaabb" [0, 6; 1, 5];
  test_search "(a)|(b)" "b" [0, 1; -1, -1; 0, 1];
  test_match "a" 0 "a" [0, 1]
