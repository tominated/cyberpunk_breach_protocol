open Base

type t = Cell.t List.t

let equal = List.equal Cell.equal

let unvisited (path : t) (coord : Coord.t) =
  not @@ List.exists path ~f:(fun cell -> Coord.equal cell.coord coord)

let to_string (path : t) =
  String.concat ~sep:", " (List.map ~f:Cell.to_string path)
