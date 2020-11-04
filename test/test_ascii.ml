let coptions = Oniguruma.coptions [||]
let roptions = Oniguruma.roptions [||]

let test_search pat str =
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

let test_match pat n str =
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
    match Oniguruma.match_ r str n roptions with
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
  test_search "a|b" "a";
  test_search "a|b" "b";
  test_search "a(a|b)" "aa";
  test_search "a(a|b)" "ab";
  test_search "a*" "";
  test_search "a*" "a";
  test_search "a*" "aa";
  test_search "a*" "aaa";
  test_search "a*b" "b";
  test_search "a*b" "ab";
  test_search "a*b" "aab";
  test_search "a(a*b)b" "aaaabb";
  test_search "(a)|(b)" "b";
  test_match "a" 0 "a"
