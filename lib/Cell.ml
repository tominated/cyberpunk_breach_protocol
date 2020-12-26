open Base

type t = {coord: Coord.t; value: string}

let to_string {coord; value} =
  Printf.sprintf "%s %s" (Coord.to_string coord) value
