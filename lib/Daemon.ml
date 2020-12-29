open Base

type t = {name: string; breach_sequence: string List.t; score: int}
[@@deriving sexp]

let to_string {name; breach_sequence; score} =
  Printf.sprintf "%s %s - score: %d" name
    (String.concat ~sep:" " breach_sequence)
    score

let equal a b =
  String.equal a.name b.name
  && List.equal String.equal a.breach_sequence b.breach_sequence
  && Int.equal a.score b.score
