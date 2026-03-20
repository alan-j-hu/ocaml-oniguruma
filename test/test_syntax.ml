let re syn str =
  match
    Oniguruma.create
      str Oniguruma.Options.none Oniguruma.Encoding.ascii
      syn
  with
  | Error e ->
    prerr_endline e;
    assert false
  | Ok r -> r

let test_syn_match syn regex str =
  match Oniguruma.match_ (re syn regex) str 0 Oniguruma.Options.none with
  | Some _ -> true
  | _ -> false

let () =
  assert (test_syn_match Oniguruma.Syntax.oniguruma "[a-b]" "a");
  assert (not (test_syn_match Oniguruma.Syntax.oniguruma "[a-b]" "[a-b]"));
  assert (test_syn_match Oniguruma.Syntax.asis "()" "()");
  assert (test_syn_match Oniguruma.Syntax.asis "[a-b]" "[a-b]");
  Oniguruma.Syntax.set_default Oniguruma.Syntax.asis;
  assert (test_syn_match (Oniguruma.Syntax.default ()) "[a-b]" "[a-b]");
  Oniguruma.Syntax.set_default Oniguruma.Syntax.grep;
  assert (test_syn_match (Oniguruma.Syntax.default ()) "a+a" "a+a");
  assert (not (test_syn_match (Oniguruma.Syntax.default ()) "a+a" "aa"));
  assert (test_syn_match (Oniguruma.Syntax.default ()) "a\\+a" "aa");
  Oniguruma.Syntax.set_default Oniguruma.Syntax.oniguruma;
  assert (test_syn_match (Oniguruma.Syntax.default ()) "a+a" "aa");
  assert (not (test_syn_match (Oniguruma.Syntax.default ()) "a+a" "a+a"))
