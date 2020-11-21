let test_search_ascii coptions roptions =
  Test_util.test_search coptions roptions Oniguruma.Encoding.ascii
let neg_test_search_ascii coptions roptions =
  Test_util.neg_test_search coptions roptions Oniguruma.Encoding.ascii
let test_search_utf8 coptions roptions =
  Test_util.test_search coptions roptions Oniguruma.Encoding.utf8
let neg_test_search_utf8 coptions roptions =
  Test_util.neg_test_search coptions roptions Oniguruma.Encoding.utf8

let () =
  let open Oniguruma.Options in
  test_search_ascii multiline search_none "." "\n" [0, 1];
  neg_test_search_ascii compile_none search_none "." "\n";
  test_search_ascii ignorecase search_none "a" "A" [0, 1];
  neg_test_search_ascii compile_none search_none "a" "A";
  test_search_ascii ignorecase search_none "A" "a" [0, 1];
  test_search_ascii ignorecase search_none "ML" "OCaml" [3, 5];
  test_search_ascii ignorecase search_none "ml" "OCaml" [3, 5];
  test_search_ascii ignorecase search_none "ML" "SML" [1, 3];
  test_search_ascii ignorecase search_none "ml" "SML" [1, 3];
  neg_test_search_ascii compile_none search_none "A" "a";
  test_search_utf8 ignorecase search_none "a" "A" [0, 1];
  neg_test_search_utf8 compile_none search_none "a" "A";
  test_search_utf8 ignorecase search_none "A" "a" [0, 1];
  neg_test_search_utf8 compile_none search_none "A" "a";
