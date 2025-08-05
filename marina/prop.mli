(** A module for manipulating boolean formulas. *)

type prop =
  | False
  | Atom of string (** Valid atoms: ^\[a-z\]+\[0-9\]*$ *)
  | Not of prop
  | And of prop * prop
  | Or of prop * prop

exception Bad_parenthesis
exception Invalid_operator
exception Invalid_atom
exception Parsing_error
val string_to_prop: string -> prop
(** [string_to_prop s] returns the prop that corresponds to string [s].
    @raise [Invalid_operator] if an invalid operator is encountered.
    @raise [Invalid_atom] if an invalid atom is encountered.
    @raise [Parsing_error] for any other parsing error. *)
