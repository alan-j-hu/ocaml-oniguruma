let coptions = Oniguruma.coptions [||]
let roptions = Oniguruma.roptions [||]

let test pat str =
  match
    Oniguruma.create
      pat coptions Oniguruma.Encoding.ascii Oniguruma.SyntaxType.oniguruma
  with
  | Error err ->
    print_endline pat;
    print_endline str;
    print_endline err;
    assert false
  | Ok r ->
    match Oniguruma.search r str 0 (String.length str) roptions with
    | None ->
      print_endline pat;
      print_endline str;
      assert false
    | Some region ->
      let num_regs = Oniguruma.num_regs region in
      print_endline (Int.to_string num_regs);
      for i = 0 to num_regs - 1 do
        print_string (Int.to_string (Oniguruma.get_beg region i));
        print_string ":";
        print_string (Int.to_string (Oniguruma.get_end region i));
        print_newline ()
      done

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
