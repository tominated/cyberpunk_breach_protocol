open Base

type t = {name: string; breach_sequence: string List.t; score: int}

let to_string {name; breach_sequence; score} =
  Printf.sprintf "%s %s - score: %d" name
    (String.concat ~sep:" " breach_sequence)
    score
