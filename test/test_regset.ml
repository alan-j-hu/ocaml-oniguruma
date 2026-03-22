let re enc coptions pat =
  match Oniguruma.create pat coptions enc (Oniguruma.Syntax.default ()) with
  | Error _ -> assert false
  | Ok re -> re

let re_utf8 = re Oniguruma.Encoding.utf8 Oniguruma.Options.none
let re1 = re_utf8 "ABC"
let re2 = re_utf8 "abc"
let re3 = re_utf8 "123"

let search regset string range_start range_end position =
  match
    Oniguruma.RegSet.search regset string range_start range_end
      position
      Oniguruma.Options.none
  with
  | None -> None
  | Some (idx, region) ->
    let open Oniguruma.Region in
    Some (idx, capture_beg region 0, capture_end region 0)

let test_regset () =
  let regset = match Oniguruma.RegSet.of_list [re1; re2] with
    | Error _ -> assert false
    | Ok regset -> regset
  in
  let search string range_start range_end position =
    match
      Oniguruma.RegSet.search regset string range_start range_end
        position
        Oniguruma.Options.none
    with
    | None -> None
    | Some (idx, region) ->
      let open Oniguruma.Region in
      Some (idx, capture_beg region 0, capture_end region 0)
  in
  assert
    (search "abc123" 0 6 Oniguruma.RegSet.POSITION_LEAD = Some (1, 0, 3));
  assert (Oniguruma.RegSet.number_of_regex regset = 2);
  Oniguruma.RegSet.add regset re3;
  assert (Oniguruma.RegSet.number_of_regex regset = 3);
  assert
    (search "abc123" 0 6 Oniguruma.RegSet.POSITION_LEAD = Some (1, 0, 3));
  assert (search "xyz" 0 6 Oniguruma.RegSet.POSITION_LEAD = None);
  assert
    (search "abcABC" 0 6 Oniguruma.RegSet.POSITION_LEAD = Some (1, 0, 3));
  assert
    (search "abcABC" 0 6 Oniguruma.RegSet.PRIORITY_TO_REGEX_ORDER
     = Some (0, 3, 6));
  assert
    (search "123ABC" 0 6 Oniguruma.RegSet.POSITION_LEAD = Some (2, 0, 3));
  let re2' = Oniguruma.RegSet.remove regset 1 in
  assert (Oniguruma.RegSet.number_of_regex regset = 2);
  assert
    (search "abcABC123" 0 9 Oniguruma.RegSet.POSITION_LEAD = Some (0, 3, 6));
  re2'

let test_regset_add_remove () =
  let regset = match Oniguruma.RegSet.of_list [] with
    | Error _ -> assert false
    | Ok regset -> regset
  in
  let try_remove_out_of_bounds idx =
    try
      let _ = Oniguruma.RegSet.remove regset idx in
      false
    with
    | Invalid_argument _ -> true
  in
  assert (try_remove_out_of_bounds 0);
  let re1 = re_utf8 "ABC" in
  Oniguruma.RegSet.add regset re1;
  assert (Oniguruma.RegSet.number_of_regex regset = 1);
  assert (try_remove_out_of_bounds 1);
  assert (try_remove_out_of_bounds 2);
  assert (try_remove_out_of_bounds (-1));
  let re2 = re_utf8 "xyz" in
  Oniguruma.RegSet.replace regset 0 re2;
  begin match Oniguruma.match_ re2 "ABC" 0 Oniguruma.Options.none with
    | None -> assert false
    | Some region ->
      assert (Oniguruma.Region.capture_beg region 0 = 0);
      assert (Oniguruma.Region.capture_end region 0 = 3)
  end;
  let re3 = Oniguruma.RegSet.remove regset 0 in
  assert (Oniguruma.RegSet.number_of_regex regset = 0);
  begin match Oniguruma.match_ re3 "xyz" 0 Oniguruma.Options.none with
    | None -> assert false
    | Some region ->
      assert (Oniguruma.Region.capture_beg region 0 = 0);
      assert (Oniguruma.Region.capture_end region 0 = 3)
  end

let () =
  let re2' = test_regset () in
  test_regset_add_remove();
  Gc.major ();
  let () =
    match Oniguruma.match_ re3 "123" 0 Oniguruma.Options.none with
    | None | Some _ -> assert false
    | exception Oniguruma.Error _ -> ()
  in
  match Oniguruma.match_ re2' "abcdef" 0 Oniguruma.Options.none with
  | None -> assert false
  | Some region ->
    assert (Oniguruma.Region.capture_beg region 0 = 0);
    assert (Oniguruma.Region.capture_end region 0 = 3)
