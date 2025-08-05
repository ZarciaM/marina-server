(** A module that contains a few utility functions. *)

val list_sub: 'a list -> int -> int -> 'a list
(** [list_sub l start len] returns a fresh list of length [len],
    containing the elements from index [start] to index [start + len - 1] of list [l]. *)
