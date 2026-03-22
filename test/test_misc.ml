let re str =
  match
    Oniguruma.create
      str Oniguruma.Options.none Oniguruma.Encoding.ascii
      (Oniguruma.Syntax.default ())
  with
  | Error e ->
    prerr_endline e;
    assert false
  | Ok r -> r

let () =
  prerr_endline Oniguruma.version;
  assert (Oniguruma.num_captures (re "a") = 0);
  assert (Oniguruma.num_captures (re "(a)") = 1);
  assert (Oniguruma.num_captures (re "(a)()") = 2);
  assert (Oniguruma.num_captures (re "(a)(b(c))") = 3);
  assert (Oniguruma.name_to_group_numbers (re "a") "x" = [||]);
  assert (Oniguruma.name_to_group_numbers (re "(?<x>)a") "x" = [|1|]);
  assert (Oniguruma.name_to_group_numbers (re "(?<x>a)(?<x>b)") "x" = [|1; 2|]);
  assert (Oniguruma.name_to_group_numbers (re "(?<x>a)(?<x>b)") "y" = [||]);
  assert (Oniguruma.name_to_group_numbers (re "(?<x>a)(?<y>b)") "x" = [|1|]);
  assert (Oniguruma.name_to_group_numbers (re "(?<x>a)(?<y>b)") "y" = [|2|]);
  let regex = re "abc" in
  match Oniguruma.match_ regex "abc" 0 Oniguruma.Options.none with
  | None -> assert false
  | Some region ->
    let test_out_of_bounds idx =
      try
        let _ = Oniguruma.Region.capture_beg region idx in
        false
      with
      | Invalid_argument _ -> true
    in
    assert (test_out_of_bounds 1);
    assert (test_out_of_bounds (-1))
