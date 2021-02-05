type typed =
  | TyString
  | TyNat
  | TyFloat
  | TyBool
  | TyUnit
  | TyArrow of typed * typed
;;

type term =
  | TmVar of string
  | TmAbs of string * typed * term
  | TmApp of term * term
  | TmLetIn of string * term * term
  | TmString of string
  | TmZero
  | TmSucc of term
  | TmPred of term
  | TmIsZero of term
  | TmFloat of float
  | TmTrue
  | TmFalse
  | TmIf of term * term * term
  | TmFix of term
  | TmUnit
;;

type command =
  | Eval of term
  | Assign of string * term
  | Open of string
  | Exit
;;