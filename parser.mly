/* Yacc grammar for the parser: parser.mli and parser.ml are generated automatically from parser.mly */

%{
  open Hashtbl;;
  open Syntax;;
  open Church;;

  let table = create 1024;;
%}

/* Keyword tokens */
%token OPEN
%token EXIT
%token LAMBDA
%token LET
%token LETREC
%token IN
%token SUCC
%token PRED
%token TRUE
%token FALSE
%token ISZERO
%token IF
%token THEN
%token ELSE
%token FIX
%token STRING
%token NAT
%token FLOAT
%token BOOL
%token UNIT
%token UNITV

/* Identifiers tokens */
%token <string> ID
%token <string> STRINGV
%token <int> INTV
%token <float> FLOATV

/* Symbolic tokens */
%token LPAREN
%token RPAREN
%token DOT
%token EQ
%token SEMI
%token COLON
%token ARROW
%token EOF

%start start
%type <Syntax.command list> start

%%

/* A sequence of commands terminated by a semicolon */
start :
    EOF
      { [] }
  | command SEMI start
      { $1::$3 }

/* The start of a command */
command :
    term
      { Eval ($1) }
  | ID EQ term
      { add table $1 $3; Assign ($1, $3) }
  | OPEN ID
      { Open ($2) }
  | EXIT
      { Exit }

/* This is the root of a type */
typed :
    atomicType
      { $1 }
  | atomicType ARROW typed
      { TyArrow ($1, $3) }

/* Atomic types are those that never need extra parentheses */
atomicType :
    LPAREN typed RPAREN
      { $2 }
  | STRING
      { TyString }
  | NAT
      { TyNat }
  | FLOAT
      { TyFloat }
  | BOOL
      { TyBool }
  | UNIT 
      { TyUnit }

/* This is the root of a term */
term :
    appTerm
      { $1 }
  | LAMBDA ID COLON typed DOT term
      { TmAbs ($2, $4, $6) }
  | LET ID EQ term IN term
      { TmLetIn ($2, $4, $6) }
  | LETREC ID COLON typed EQ term IN term
      { TmLetIn ($2, TmFix (TmAbs ($2, $4, $6)), $8) }
  | IF term THEN term ELSE term
      { TmIf ($2, $4, $6) }

/* App terms are those that are followed by an atomic term */
appTerm :
    atomicTerm
      { $1 }
  | appTerm atomicTerm
      { TmApp ($1, $2) }
  | SUCC atomicTerm
      { TmSucc ($2) }
  | PRED atomicTerm
      { TmPred ($2) }
  | ISZERO atomicTerm
      { TmIsZero ($2) }
  | FIX atomicTerm
      { TmFix ($2) }

/* Atomic terms are those that never require extra parentheses */
atomicTerm :
    LPAREN term RPAREN
      { $2 }
  | ID
      { try find table $1 with Not_found -> TmVar ($1) }
  | STRINGV
      { TmString ($1) }
  | INTV
      { num_to_term $1 }
  | FLOATV
      { TmFloat ($1) }
  | TRUE
      { TmTrue }
  | FALSE
      { TmFalse }
  | UNITV
      { TmUnit }