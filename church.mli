open Syntax;;

exception Invalid_term;;

(* Get the equivalent church encoding of a number *)
val num_to_term : int -> term;;

(* Get the equivalent number of a church encoding or an error if the term is incorrect *)
val term_to_num : term -> int;;