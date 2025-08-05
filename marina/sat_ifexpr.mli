(** A module that provides a SAT solver; technique used: IF-expressions.
    @see <https://www.lri.fr/~filliatr/ftp/tp-info/IFexpressions.ps.gz> IF-expressions *)

val sat_ifexpr: Prop.prop -> (string * bool) list
(** [sat_ifexpr p] returns a partial assignment for the variables
    if proposition [p] is satisfiable. A partial assignment is a list of couples
    (variable name, boolean value).
    If [p] is unsatisfiable then returns [(,false)]. *)
