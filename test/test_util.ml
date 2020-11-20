let coptions = Oniguruma.Option.coptions [||]
let roptions = Oniguruma.Option.roptions [||]

let check_out_of_bounds regs idx =
  try ignore (Oniguruma.Region.cap_beg regs idx); assert false with
  | Oniguruma.Error _ -> ()

let check_against regs exp_regs =
  let num_regs = Oniguruma.Region.length regs in
  check_out_of_bounds regs (-1);
  check_out_of_bounds regs num_regs;
  let rec loop i num_regs exp_regs = match num_regs, exp_regs with
    | 0, [] -> ()
    | 0, _ :: _ -> assert false
    | _, [] -> assert false
    | n, (exp_beg, exp_end) :: exp_regs ->
      assert (Oniguruma.Region.cap_beg regs i = exp_beg);
      assert (Oniguruma.Region.cap_end regs i = exp_end);
      loop (i + 1) (n - 1) exp_regs
  in loop 0 num_regs exp_regs

let test_search coptions roptions enc pat str exp_regs =
  let coptions = Oniguruma.Option.coptions coptions in
  let roptions = Oniguruma.Option.roptions roptions in
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
  | Error err ->
    prerr_endline pat;
    prerr_endline str;
    prerr_endline err;
    assert false
  | Ok r ->
    match Oniguruma.search r str 0 (String.length str) roptions with
    | None ->
      prerr_endline pat;
      prerr_endline str;
      assert false
    | Some region ->
      check_against region exp_regs

let neg_test_search coptions roptions enc pat str =
  let coptions = Oniguruma.Option.coptions coptions in
  let roptions = Oniguruma.Option.roptions roptions in
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
  | Error err ->
    prerr_endline pat;
    prerr_endline str;
    prerr_endline err;
    assert false
  | Ok r ->
    match Oniguruma.search r str 0 (String.length str) roptions with
    | None -> ()
    | Some _ -> assert false

let test_search_out_of_bounds coptions roptions enc pat str s_beg s_end =
  let coptions = Oniguruma.Option.coptions coptions in
  let roptions = Oniguruma.Option.roptions roptions in
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
  | Error err ->
    prerr_endline pat;
    prerr_endline str;
    prerr_endline err;
    assert false
  | Ok r ->
    match Oniguruma.search r str s_beg s_end roptions with
    | None -> ()
    | Some _ -> assert false

let test_match coptions roptions enc pat n str exp_regs =
  let coptions = Oniguruma.Option.coptions coptions in
  let roptions = Oniguruma.Option.roptions roptions in
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
  | Error err ->
    prerr_endline pat;
    prerr_endline str;
    prerr_endline err;
    assert false
  | Ok r ->
    match Oniguruma.match_ r str n roptions with
    | None ->
      prerr_endline pat;
      prerr_endline str;
      assert false
    | Some region ->
      check_against region exp_regs

let neg_test_match coptions roptions enc pat n str =
  let coptions = Oniguruma.Option.coptions coptions in
  let roptions = Oniguruma.Option.roptions roptions in
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
  | Error err ->
    prerr_endline pat;
    prerr_endline str;
    prerr_endline err;
    assert false
  | Ok r ->
    match Oniguruma.match_ r str n roptions with
    | None -> ()
    | Some _ -> assert false

let test_match_out_of_bounds coptions roptions enc pat str pos =
  let coptions = Oniguruma.Option.coptions coptions in
  let roptions = Oniguruma.Option.roptions roptions in
  match Oniguruma.create pat coptions enc Oniguruma.Syntax.oniguruma with
  | Error err ->
    prerr_endline pat;
    prerr_endline str;
    prerr_endline err;
    assert false
  | Ok r ->
    match Oniguruma.match_ r str pos roptions with
    | None -> ()
    | Some _ -> assert false
