let coptions = Oniguruma.coptions [||]
let roptions = Oniguruma.roptions [||]

let test_search enc pat str exp_regs =
  match Oniguruma.create pat coptions enc Oniguruma.SyntaxType.oniguruma with
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
      let rec loop i num_regs exp_regs = match num_regs, exp_regs with
        | 0, [] -> ()
        | 0, _ :: _ -> assert false
        | _, [] -> assert false
        | n, (exp_beg, exp_end) :: exp_regs ->
          assert (Oniguruma.get_beg region i = exp_beg);
          assert (Oniguruma.get_end region i = exp_end);
          loop (i + 1) (n - 1) exp_regs
      in loop 0 num_regs exp_regs

let test_match enc pat n str exp_regs =
  match Oniguruma.create pat coptions enc Oniguruma.SyntaxType.oniguruma with
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
      let rec loop i num_regs exp_regs = match num_regs, exp_regs with
        | 0, [] -> ()
        | 0, _ :: _ -> assert false
        | _, [] -> assert false
        | n, (exp_beg, exp_end) :: exp_regs ->
          assert (Oniguruma.get_beg region i = exp_beg);
          assert (Oniguruma.get_end region i = exp_end);
          loop (i + 1) (n - 1) exp_regs
      in loop 0 num_regs exp_regs
