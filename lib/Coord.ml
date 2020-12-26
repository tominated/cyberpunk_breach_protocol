open Base

type t = int * int

let equal (x1, y1) (x2, y2) = Int.equal x1 x2 && Int.equal y1 y2

let to_string (x, y) = Printf.sprintf "(%d, %d)" x y
