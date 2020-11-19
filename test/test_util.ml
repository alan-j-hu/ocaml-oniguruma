let coptions = Oniguruma.coptions [||]
let roptions = Oniguruma.roptions [||]

let check_against regs exp_regs =
  let num_regs = Oniguruma.Region.length regs in
  let rec loop i num_regs exp_regs = match num_regs, exp_regs with
    | 0, [] -> ()
    | 0, _ :: _ -> assert false
    | _, [] -> assert false
    | n, (exp_beg, exp_end) :: exp_regs ->
      assert (Oniguruma.Region.reg_beg regs i = exp_beg);
      assert (Oniguruma.Region.reg_end regs i = exp_end);
      loop (i + 1) (n - 1) exp_regs
  in loop 0 num_regs exp_regs

let test_search enc pat str exp_regs =
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
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
      check_against region exp_regs

let neg_test_search enc pat str =
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
  | Error err ->
    print_endline pat;
    print_endline str;
    print_endline err;
    assert false
  | Ok r ->
    match Oniguruma.search r str 0 (String.length str) roptions with
    | None -> ()
    | Some _ -> assert false

let test_match enc pat n str exp_regs =
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
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
      check_against region exp_regs

let neg_test_match enc pat n str =
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
  | Error err ->
    print_endline pat;
    print_endline str;
    print_endline err;
    assert false
  | Ok r ->
    match Oniguruma.match_ r str n roptions with
    | None -> ()
    | Some _ -> assert false
