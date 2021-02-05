open Syntax;;
open Church;;

let rec string_of_type ty = match ty with
  | TyArrow (ty1, ty2) ->
      string_of_atomicType ty1 ^ " -> " ^ string_of_type ty2
  | _ ->
      string_of_atomicType ty

and string_of_atomicType ty = match ty with
  | TyString ->
      "String"
  | TyNat ->
      "Nat"
  | TyFloat ->
      "Float"
  | TyBool ->
      "Bool"
  | TyUnit -> 
      "Unit"
  | _ ->
      "(" ^ string_of_type ty ^ ")"
;;

let rec string_of_term t = match t with
  | TmAbs (s, ty1, t2) ->
      "λ" ^ s ^ ":" ^ string_of_type ty1 ^ ". " ^ string_of_term t2
  | TmLetIn (s, t1, t2) ->
      "let " ^ s ^ " = " ^ string_of_term t1 ^ " in " ^ string_of_term t2
  | TmIf (t1, t2, t3) ->
      "if " ^ string_of_term t1 ^ " then " ^ string_of_term t2 ^ " else " ^ string_of_term t3
  | _ ->
      string_of_appTerm t

and string_of_appTerm t = match t with
  | TmApp (t1, t2) ->
      string_of_appTerm t1 ^ " " ^ string_of_appTerm t2
  | TmSucc (t1) -> begin
      try
        string_of_int (1+term_to_num t1)
      with Invalid_term ->
        "(succ " ^ string_of_atomicTerm t1 ^ ")"
    end
  | TmPred (t1) ->
      "(pred " ^ string_of_atomicTerm t1 ^ ")"
  | TmIsZero (t1) ->
      "iszero " ^ string_of_atomicTerm t1
  | TmFix (t1) ->
      "fix " ^ string_of_atomicTerm t1
  | _ ->
      string_of_atomicTerm t

and string_of_atomicTerm t = match t with
  | TmVar (s) ->
      s
  | TmString (s) ->
      "\"" ^ s ^ "\""
  | TmZero ->
      "0"
  | TmFloat (s) ->
      string_of_float s
  | TmTrue ->
      "true"
  | TmFalse ->
      "false"
  | TmUnit ->
      "()"
  | _ ->
      "(" ^ string_of_term t ^ ")"
;;