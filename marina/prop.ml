type prop =
  | False
  | Atom of string
  | Not of prop
  | And of prop * prop
  | Or of prop * prop
let imp p q = Or (Not p, q)
let equiv p q = And (imp p q, imp q p)



(* Seems that there is no regex for whitespaces in OCaml.
   So have to split then trim. *)
let rec splits_to_strs = function
  | [] -> []
  | (Str.Delim str)::tokens -> [String.trim str]@(splits_to_strs tokens)
  | (Str.Text str)::tokens -> [String.trim str]@(splits_to_strs tokens)
let rec remove_voids = function
  | [] -> []
  | ""::strs -> remove_voids strs
  | nonvoid::strs -> [nonvoid]@(remove_voids strs)
let tokenize str =
  remove_voids (splits_to_strs (
      Str.full_split (Str.regexp "[~()&|]\\|<->\\|->") str))



(* HighLevelToken: an operator, or an Atom, or (...)*, or ~(...) *)
exception Bad_parenthesis
let rec cuthd_hltoken tokens = match tokens with
  | [] -> ([],[])
  | "("::tokens' ->
    let rec matchingpar_idx = (function
        | (unmatched_par,j,[]) -> (unmatched_par,j,[])
        | (0,j,l) -> (0,j,l)
        | (unmatched_par,j,"("::l) -> matchingpar_idx (unmatched_par+1, j+1, l)
        | (unmatched_par,j,")"::l) -> matchingpar_idx (unmatched_par-1, j+1, l)
        | (unmatched_par,j,_::l) -> matchingpar_idx (unmatched_par, j+1, l)) in
    begin match matchingpar_idx (1,1,tokens') with
      | (0,2,l) -> raise Bad_parenthesis (* "()" is a syntax error *)
      | (0,j,l) ->
        (My.list_sub tokens 0 j,
         My.list_sub tokens j ((List.length tokens)-j))
      | _ -> raise Bad_parenthesis
    end
  | "~"::"("::tokens' ->
    let (parexpr_hd,parexpr_tl) = cuthd_hltoken (["("]@tokens') in
    (["~"]@parexpr_hd,parexpr_tl)
  | "~"::atom::tokens' -> cuthd_hltoken (["~";"(";atom;")"]@tokens')
  | token::tokens' -> ([token],tokens')

let rec tokens_to_hltokens hltokens = match cuthd_hltoken hltokens with
  | (hltoken,[]) -> [hltoken]
  | (hltoken,hltokens') -> [hltoken]@(tokens_to_hltokens hltokens')

exception Invalid_operator
let priority op =
  let priority_str opchar = String.index "&|%#" opchar in
  match op with
  | "->" -> priority_str '%'
  | "<->" -> priority_str '#'
  | "&" -> priority_str '&'
  | "|" -> priority_str '|'
  | _ -> raise Invalid_operator

exception Invalid_atom
exception Parsing_error
let rec hltokens_to_prop hltokens = match hltokens with
  | [["F"]] -> False
  | [["T"]] -> Not False
  | ["("::tokens] ->
    let without_par = My.list_sub tokens 0 ((List.length tokens)-1) in
    hltokens_to_prop (tokens_to_hltokens without_par)
  | ["~"::tokens] -> Not (hltokens_to_prop (tokens_to_hltokens tokens))
  | [[at]] ->
    if Str.string_match (Str.regexp "^[a-z_]+[0-9]*$") at 0 then Atom at else
      raise Invalid_atom
  | operand1::op::hltokens' ->
    let highestop_idx = ref 1 in
    let curop_idx = ref 1 in
    let highestpr =
      ref (priority (List.nth (List.nth hltokens !curop_idx) 0)) in
    while !curop_idx < (List.length hltokens) do
      let curpr = priority (List.nth (List.nth hltokens !curop_idx) 0) in
      if curpr < !highestpr then begin
        highestpr := curpr;
        highestop_idx := !curop_idx
      end;
      curop_idx := !curop_idx + 2
    done;
    let prop1 = hltokens_to_prop (My.list_sub hltokens 0 !highestop_idx) in
    let prop2 = hltokens_to_prop
      (My.list_sub hltokens (!highestop_idx+1) ((List.length hltokens) - !highestop_idx - 1))
    in
    begin match List.nth hltokens !highestop_idx with
      | ["&"] -> And (prop1,prop2)
      | ["|"] -> Or (prop1,prop2)
      | ["->"] -> imp prop1 prop2
      | ["<->"] -> equiv prop1 prop2
      | _ -> raise Invalid_operator
    end
  | _ -> raise Parsing_error

let string_to_prop pstr = hltokens_to_prop (tokens_to_hltokens (tokenize pstr))
