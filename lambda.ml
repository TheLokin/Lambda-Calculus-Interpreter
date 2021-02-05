open Syntax;;
open Utils;;

exception NoRuleApplies;;

let rec is_num = function
  | TmZero ->
      true
  | TmSucc (t1) ->
      is_num t1
  | _ ->
      false
;;

let rec is_val = function
  | TmVar _ | TmAbs _ | TmString _ | TmFloat _ | TmTrue | TmFalse | TmUnit ->
      true
  | term when is_num term ->
      true
  | _ ->
      false
;;

let rec free_vars = function
  | TmVar (s) ->
      [s]
  | TmAbs (s, _, t) ->
      ldif (free_vars t) [s]
  | TmApp (t1, t2) ->
      lunion (free_vars t1) (free_vars t2)
  | TmLetIn (s, t1, t2) ->
      lunion (ldif (free_vars t2) [s]) (free_vars t1)
  | TmString _ | TmZero | TmFloat _ | TmTrue | TmFalse | TmUnit ->
      []
  | TmSucc (t) | TmPred (t) | TmIsZero (t) | TmFix (t) ->
      free_vars t
  | TmIf (t1, t2, t3) ->
      lunion (free_vars t1) (lunion (free_vars t2) (free_vars t3))
;;

let rec fresh_name s fvs =
  if List.mem s fvs then
    fresh_name (s ^ "'") fvs
  else s
;;

let rec subst x s t = match t with
  | TmVar (y) when x = y ->
      s
  | TmVar _ ->
      t
  | TmAbs (y, _, _) when x = y ->
      t
  | TmAbs (y, ty1, t2) ->
      let fvs = free_vars s in
      if not (List.mem y fvs) then
        TmAbs (y, ty1, subst x s t2)
      else let z = fresh_name y (free_vars t2 @ fvs) in
        TmAbs (z, ty1, subst x s (subst y (TmVar (z)) t2))
  | TmApp (t1, t2) ->
      TmApp (subst x s t1, subst x s t2)
  | TmLetIn (y, t1, t2) when x = y ->
      TmLetIn (y, subst x s t1, t2)
  | TmLetIn (y, t1, t2) ->
      TmLetIn (y, subst x s t1, subst x s t2)
  | TmString _ ->
      t
  | TmZero ->
      t
  | TmSucc (t1) ->
      TmSucc (subst x s t1)
  | TmPred (t1) ->
      TmPred (subst x s t1)
  | TmIsZero (t1) ->
      TmIsZero (subst x s t1)
  | TmFloat _ ->
      t
  | TmTrue ->
      t
  | TmFalse ->
      t
  | TmIf (t1, t2, t3) ->
      TmIf (subst x s t1, subst x s t2, subst x s t3)
  | TmFix (t1) ->
      TmFix (subst x s t1)
  | TmUnit ->
      t
;;

let rec eval_term = function
  | TmApp (TmAbs (s, _, t1), v2) when is_val v2 ->
      subst s v2 t1
  | TmApp (v1, t2) when is_val v1 ->
      let t2' = eval_term t2 in
      TmApp (v1, t2')
  | TmApp (t1, t2) ->
      let t1' = eval_term t1 in
      TmApp (t1', t2)
  | TmLetIn (s, v1, t2) when is_val v1 ->
      subst s v1 t2
  | TmLetIn (s, t1, t2) ->
      let t1' = eval_term t1 in
      TmLetIn (s, t1', t2)
  | TmSucc (t1) ->
      let t1' = eval_term t1 in
      TmSucc (t1')
  | TmPred (TmZero) ->
      TmZero
  | TmPred (TmSucc (n1)) when is_num n1 ->
      n1
  | TmPred (t1) ->
      let t1' = eval_term t1 in
      TmPred (t1')
  | TmIsZero (TmZero) ->
      TmTrue
  | TmIsZero (TmSucc (n1)) when is_num n1 ->
      TmFalse
  | TmIsZero (t1) ->
      let t1' = eval_term t1 in
      TmIsZero (t1')
  | TmIf (TmTrue, t2, t3) ->
      t2
  | TmIf (TmFalse, t2, t3) ->
      t3
  | TmIf (t1, t2, t3) ->
      let t1' = eval_term t1 in
      TmIf (t1', t2, t3)
  | TmFix (TmAbs (s, _, t12) as v1) ->
      subst s (TmFix v1) t12
  | TmFix (t1) ->
      let t1' = eval_term t1 in
      TmFix (t1')
  | _ ->
      raise NoRuleApplies
;;

let rec eval term =
  try
    let term' = eval_term term in
    eval term'
  with
    NoRuleApplies -> term
;;