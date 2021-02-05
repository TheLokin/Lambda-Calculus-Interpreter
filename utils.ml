let rec ldif l1 l2 = match l1 with
  | [] ->
      []
  | h::t ->
      if List.mem h l2 then ldif t l2
      else h::(ldif t l2)
;;

let rec lunion l1 l2 = match l1 with
  | [] ->
      l2
  | h::t ->
      if List.mem h l2 then lunion t l2
      else h::(lunion t l2)
;;