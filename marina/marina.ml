let sat = Sat_ifexpr.sat_ifexpr

let sat_pstr pstr = sat (Prop.string_to_prop pstr)

let string_of_assign (at,boolval) =
  String.concat "" ["(";at;",";string_of_bool boolval;")"]
let string_of_assigns assigns =
  List.fold_right
    (fun assign s -> String.concat " " [string_of_assign assign;s])
    assigns ""

let sat_str pstr = String.trim (string_of_assigns (sat_pstr pstr));;

