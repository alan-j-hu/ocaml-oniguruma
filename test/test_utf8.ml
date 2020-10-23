let coptions = Oniguruma.coptions [||]
let roptions = Oniguruma.roptions [||]

let test pat str =
  match
    Oniguruma.create
      pat coptions Oniguruma.Encoding.utf8 Oniguruma.SyntaxType.oniguruma
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
  test "あ" "あ";
  test "あ*" "";
  test "あ*" "あ";
  test "あ|a" "a";
  test "あ|a" "あ"
