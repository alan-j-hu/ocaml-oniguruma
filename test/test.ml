let test pat str =
  match
    Oniguruma.create
      pat [||] Oniguruma.Encoding.ascii Oniguruma.SyntaxType.oniguruma
  with
  | Error err ->
    print_endline pat;
    print_endline str;
    print_endline err;
    assert false
  | Ok r ->
    match Oniguruma.search r str 0 (String.length str) [||] with
    | None ->
      print_endline pat;
      print_endline str;
      assert false
    | Some _ ->
      ()

let () =
  test "a|b" "a";
  test "a|b" "b";
  test "a(a|b)" "aa";
  test "a(a|b)" "ab";
  test "a*" "";
  test "a*" "a";
  test "a*" "aa";
  test "a*" "aaa";
  test "a*b" "b";
  test "a*b" "ab";
  test "a*b" "aab";
  test "a(a*b)b" "aaaabb";
