open Parsing;;
open Lexing;;

open Parser;;
open Lexer;;

open Syntax;;
open Lambda;;
open Types;;
open Print;;

open String;;

let process_file file =
  let rec trynext = function
    | [] ->
        raise (Failure ("Could not find " ^ file ^ ".lambda"))
    | path::tail ->
        let name = if path = "" then file else path ^ "/" ^ file in
        try
          let id = open_in (name ^ ".lambda") in
          let commands = start token (from_channel id) in
          close_in id;
          commands
        with
          | Sys_error _ ->
              trynext tail
  in trynext ["samples"; ""]
;;

let rec process_line line =
  if contains line ';' then start token (from_string (sub line 0 (1+index line ';')))
  else begin
    print_string "  ";
    flush stdout;
    process_line (line ^ "\n" ^ read_line ())
  end
;;

let rec execute = function
    | [] ->
        ()
    | Eval (term)::tail ->
        print_endline ("- " ^ string_of_term (eval term) ^ " : " ^ string_of_type (typeof term));
        execute tail
    | Assign (name, term)::tail ->
        print_endline ("- " ^ name ^ " : " ^ string_of_type (typeof term));
        execute tail
    | Open (file)::tail ->
        execute (process_file file);
        execute tail
    | Exit::_ ->
        raise End_of_file
;;

let top_level () =
  print_endline "Welcome to the lambda calculus interpreter";
  let rec loop () =
    print_string "# ";
    flush stdout;
    try
      let line = trim (read_line ()) in
      if length line = 0 then loop ()
      else execute (process_line line);
      loop ()
    with
      | Lexical_error e ->
          print_endline ("\027[1m\027[31mError\027[0m: " ^ e);
          loop ()
      | Parse_error ->
          print_endline "\027[1m\027[31mError\027[0m: Syntax error";
          loop ()
      | Type_error e ->
          print_endline ("\027[1m\027[31mError\027[0m: " ^ e);
          loop ()
      | Failure e ->
          print_endline ("\027[1m\027[31mError\027[0m: " ^ e);
          loop ()
      | End_of_file ->
          ()
  in loop ()
;;

top_level ();;