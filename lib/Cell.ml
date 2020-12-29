open Base

type t = {coord: Coord.t; value: string} [@@deriving sexp]

let equal a b = Coord.equal a.coord b.coord && String.equal a.value b.value

let to_string {coord; value} =
  Printf.sprintf "%s %s" (Coord.to_string coord) value
