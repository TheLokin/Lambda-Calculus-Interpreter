open Syntax;;

exception Type_error of string;;

let rec type_equal ty1 ty2 = match (ty1, ty2) with
  | (TyString, TyString) ->
      true
  | (TyNat, TyNat) ->
      true
  | (TyFloat, TyFloat) ->
      true
  | (TyBool, TyBool) ->
      true
  | (TyUnit, TyUnit) ->
      true
  | (TyArrow (ty11, ty12), TyArrow (ty21, ty22)) ->
      type_equal ty11 ty21 && type_equal ty12 ty22
  | _ ->
      false
;;

let typeof term =
    let rec loop context term = match term with
      | TmVar (s) -> 
          let rec aux context = match context with
            | [] ->
                raise (Type_error ("Unknown type of " ^ s))
            | (name, ty)::context when s = name ->
                ty
            | _::context ->
                aux context
          in aux context
      | TmAbs (s, ty1, t2) ->
          let context' = (s, ty1)::context in
          let ty2 = loop context' t2 in
          TyArrow (ty1, ty2)
      | TmApp (t1, t2) -> begin
          let ty1 = loop context t1 in
          let ty2 = loop context t2 in
          match ty1 with
            | TyArrow (ty11, ty12) ->
                if type_equal ty2 ty11 then
                  ty12
                else raise (Type_error "Parameter type mismatch")
            | _ ->
                raise (Type_error "Arrow type expected")
          end
      | TmLetIn (s, t1, t2) ->
          let ty1 = loop context t1 in
          let context' = (s, ty1)::context in
          loop context' t2
      | TmString _ ->
          TyString
      | TmZero ->
          TyNat
      | TmSucc (t) ->
          if TyNat = loop context t then
            TyNat
          else raise (Type_error "'succ' was expected an argument of type Nat")
      | TmPred (t) ->
          if TyNat = loop context t then
            TyNat
          else raise (Type_error "'pred' was expected an argument of type Nat")
      | TmFloat _ ->
          TyFloat
      | TmTrue ->
          TyBool
      | TmFalse ->
          TyBool
      | TmIsZero (t) ->
          if TyNat = loop context t then
            TyBool
          else raise (Type_error "'iszero' was expected an argument of type Nat")
      | TmIf (t1, t2, t3) -> begin
          match (loop context t1, loop context t2, loop context t3) with
            | (TyBool, ty1, ty2) when ty1 = ty2 ->
                ty1
            | (_, ty1, ty2) when ty1 = ty2 ->
                raise (Type_error "'if' was expected a guard of type Bool")
            | _ ->
                raise (Type_error "'if' was expected a result of the same type")
          end
      | TmFix (t) -> begin
          match loop context t with
              | TyArrow (ty1, ty2) ->
                  if type_equal ty1 ty2 then
                    ty1
                  else raise (Type_error "Result of body not compatible with domain")
              | _ ->
                  raise (Type_error "Arrow type expected")
          end
      | TmUnit ->
          TyUnit
    in loop [] term
;;