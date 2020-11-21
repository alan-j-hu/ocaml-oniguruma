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
  test_search_ascii [|MULTILINE|] [||] "." "\n" [0, 1];
  neg_test_search_ascii [||] [||] "." "\n";
  test_search_ascii [|IGNORECASE|] [||] "a" "A" [0, 1];
  neg_test_search_ascii [||] [||] "a" "A";
  test_search_ascii [|IGNORECASE|] [||] "A" "a" [0, 1];
  test_search_ascii [|IGNORECASE|] [||] "ML" "OCaml" [3, 5];
  test_search_ascii [|IGNORECASE|] [||] "ml" "OCaml" [3, 5];
  test_search_ascii [|IGNORECASE|] [||] "ML" "SML" [1, 3];
  test_search_ascii [|IGNORECASE|] [||] "ml" "SML" [1, 3];
  neg_test_search_ascii [||] [||] "A" "a";
  test_search_utf8 [|IGNORECASE|] [||] "a" "A" [0, 1];
  neg_test_search_utf8 [||] [||] "a" "A";
  test_search_utf8 [|IGNORECASE|] [||] "A" "a" [0, 1];
  neg_test_search_utf8 [||] [||] "A" "a";
