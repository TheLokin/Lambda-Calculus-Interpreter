(* The lexical analyzer: lexer.ml is generated automatically from lexer.mll *)

{
  open Lexing;;
  open Parser;;
  open Bytes;;

  exception Lexical_error of string;;

  (* Support functions for comments *)
  let comments = ref 0;;

  let open_comment () =
    comments := !comments+1
  ;;

  let close_comment () =
    comments := !comments-1;
    !comments > 0
  ;;

  let reset_comments () =
    comments := 1
  ;;

  (* Support functions for strings *)
  let buffer = ref (create 1024);;
  let position = ref 0;;

  let add_char char =
    if !position = length !buffer then begin
      let new_buffer = create (!position*2) in
      blit !buffer 0 new_buffer 0 !position;
      set new_buffer !position char;
      buffer := new_buffer;
    end else set !buffer !position char;
    position := !position + 1
  ;;

  let get_string () =
    sub !buffer 0 !position
  ;;

  let reset_string () =
    position := 0
  ;;
}

rule token = parse
  | [' ' '\t' '\r' '\n']*
      { token lexbuf }
  | '\"'
      {
        reset_string ();
        string lexbuf
      }
  | '('
      { LPAREN }
  | ')'
      { RPAREN }
  | '.'
      { DOT }
  | '='
      { EQ }
  | ';'
      { SEMI }
  | ':'
      { COLON }
  | "->"
      { ARROW }
  | "*)"
      { raise (Lexical_error "Unmatched end of comment") }
  | "(*"
      {
        reset_comments ();
        comment lexbuf;
        token lexbuf
      }
  | "open"
      { OPEN }
  | "exit"
      { EXIT }
  | "lambda" | "L" | "λ"
      { LAMBDA }
  | "let"
      { LET }
  | "letrec"
      { LETREC }
  | "in"
      { IN }
  | "succ"
      { SUCC }
  | "pred"
      { PRED }
  | "true"
      { TRUE }
  | "false"
      { FALSE }
  | "iszero"
      { ISZERO }
  | "if"
      { IF }
  | "then"
      { THEN }
  | "else"
      { ELSE }
  | "fix"
      { FIX }
  | "String"
      { STRING }
  | "Nat"
      { NAT }
  | "Float"
      { FLOAT }
  | "Bool"
      { BOOL }
  | "Unit"
      { UNIT }
  | "()"
      { UNITV }
  | "unit"
      { UNITV }
  | ['0'-'9']+
      { INTV (int_of_string (lexeme lexbuf)) }
  | ['0'-'9']+'.'['0'-'9']+
      { FLOATV (float_of_string (lexeme lexbuf)) }
  | ['A'-'Z' 'a'-'z' '_']['A'-'Z' 'a'-'z' '_' '0'-'9' '\'']*
      { ID (lexeme lexbuf) }
  | eof
      { EOF }
  | _
      { raise (Lexical_error ("Illegal character " ^ lexeme lexbuf)) }

and string = parse
  | '\"'
      { STRINGV (get_string ()) }
  | '\\'
      {
        add_char (escaped lexbuf);
        string lexbuf
      }
  | eof
      { raise (Lexical_error "String not terminated") }
  | _
      {
        add_char (lexeme_char lexbuf 0);
        string lexbuf
      }

and escaped = parse
  | 't'
      { '\t' }
  | 'n'
      { '\n' }
  | '\\'
      { '\\' }
  | '\"'
      { '\"' }
  | '\''
      { '\'' }
  | ['0'-'9']['0'-'9']['0'-'9']
      {
        let char = int_of_string (lexeme lexbuf) in
        if char > 255 then raise (Lexical_error ("Illegal character constant"))
        else Char.chr char
      }
  | _
      { raise (Lexical_error ("Illegal character constant")) }

and comment = parse
  | "(*"
      {
        open_comment ();
        comment lexbuf
      }
  | "*)"
      { if close_comment () then comment lexbuf }
  | eof
      { raise (Lexical_error "Comment not terminated") }
  | _
      { comment lexbuf }