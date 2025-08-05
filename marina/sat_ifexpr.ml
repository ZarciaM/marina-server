type ifexpr =
  | FalseIf
  | TrueIf
  | AtomIf of string
  | If of ifexpr * ifexpr * ifexpr

let rec prop_to_if = function
  | Prop.False -> FalseIf
  | Prop.Atom at -> AtomIf at
  | Prop.Not p -> If (prop_to_if p, FalseIf, TrueIf)
  | Prop.And (p,q) -> If (prop_to_if p, prop_to_if q, FalseIf)
  | Prop.Or (p,q) -> If (prop_to_if p, TrueIf, prop_to_if q)

let rec normalize = function
  | FalseIf -> FalseIf
  | TrueIf -> TrueIf
  | AtomIf at -> AtomIf at
  | If (FalseIf, pif, qif) -> normalize qif
  | If (TrueIf, pif, qif) -> normalize pif
  | If (AtomIf at, bif, cif) -> If (AtomIf at, normalize bif, normalize cif)
  | If (If (aif, bif, cif), pif, qif) ->
    normalize (If (
        aif,
        normalize (If (bif, pif, qif)),
        normalize (If (cif, pif, qif))  ))

let rec val_wrt_assigns at = function
  | [] -> (false,false)
  | (at_in_assigns,val_in_assigns)::assigns' ->
    if at = at_in_assigns then (true,val_in_assigns) else
      val_wrt_assigns at assigns'

exception Nonnormalized_ifexpr
let rec sat_ifn ifn assigns = match ifn with
  | FalseIf -> [("",false)]
  | TrueIf -> assigns
  | AtomIf at -> begin match val_wrt_assigns at assigns with
      | (false,_) -> assigns@[(at,true)]
      | (true,true) -> assigns
      | (true,false) -> [("",false)]
    end
  | If (AtomIf at, bif, cif ) ->
    begin match val_wrt_assigns at assigns with
      | (false,_) -> let truebranch = sat_ifn bif (assigns@[(at,true)]) in
        begin match truebranch with
          | [("",false)] -> sat_ifn cif (assigns@[(at,false)])
          | _ -> truebranch
        end
      | (true,true) -> sat_ifn bif assigns
      | (true,false) -> sat_ifn cif assigns
    end
  | _ -> raise Nonnormalized_ifexpr

let sat_ifexpr p = sat_ifn (normalize (prop_to_if p)) []
