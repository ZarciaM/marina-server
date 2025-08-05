(* open Prop (* Directive is intentionaly left open despite guidelines *)
let p1 = And (Or (Not (Atom "a"), Atom "b"), Atom "c")
let p2 = Or (And (Atom "a", Atom "b"), And (Not (Atom "c"), Atom "d")) *)

open OUnit2

let test_sat1 _ =
  let input = "(a&b | ~c) -> d<->e" in
  let output = Marina.sat_str input in
  let expected = "(a,true) (b,true) (d,true) (e,true)" in
  assert_equal expected output

let test_sat2 _ =
  let input = "~(a -> b|c) <-> ~c&d" in
  let output = Marina.sat_str input in
  let expected = "(a,true) (b,true) (c,true) (d,true)" in
  assert_equal expected output

let test_unsat1 _ =
  let input = "a & ~(a)" in
  let output = Marina.sat_str input in
  let expected = "(,false)" in
  assert_equal expected output

let test_bad_parenthesis1 _ =
  let input = "~(a -> (b)" in
  assert_raises Prop.Bad_parenthesis (fun () -> Marina.sat_str input)

let test_bad_parenthesis2 _ =
  let input = "~() a" in
  assert_raises Prop.Bad_parenthesis (fun () -> Marina.sat_str input)

let suite =
  "SatIT" >::: [
    "test_sat1" >:: test_sat1;
    "test_sat2" >:: test_sat2;
    "test_unsat1" >:: test_unsat1;
    "test_bad_parenthesis1" >:: test_bad_parenthesis1;
    "test_bad_parenthesis2" >:: test_bad_parenthesis2
  ]

let () =
  run_test_tt_main suite