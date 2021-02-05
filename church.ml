open Syntax;;

exception Invalid_term;;

let num_to_term n =
  let rec aux i t =
    if n = i then t
    else aux (i+1) (TmSucc (t))
  in aux 0 (TmZero)
;;

let term_to_num term =
  let rec aux i = function
    | TmZero ->
        i
    | TmSucc (t) ->
        aux (i+1) t
    | _ ->
        raise Invalid_term
  in aux 0 term
;;