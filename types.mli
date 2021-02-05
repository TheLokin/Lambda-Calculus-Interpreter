open Syntax;;

exception Type_error of string;;

(* Returns the type of a term *)
val typeof : term -> typed;;