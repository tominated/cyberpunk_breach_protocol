open Base

type daemon = { name : string ; breach_sequence : string List.t }

let range n = List.init n ~f:Fn.id

module Coord = struct
  type t = int * int

  let equal (x1, y1) (x2, y2) = (Int.equal x1 x2) && (Int.equal y1 y2)

  let to_string (x, y) = Printf.sprintf "(%d, %d)" x y
end

module BreachMatrix = struct
  type cell = { coord: Coord.t; value: string }
  type t = cell Array.t Array.t

  let of_list (list: string List.t List.t) : t =
    List.mapi list ~f:(fun y row ->
      List.mapi row ~f:(fun x value -> { coord = (x, y); value })
      |> Array.of_list
    ) |> Array.of_list
  
  let to_string matrix =
    Array.fold matrix ~init:"" ~f:(fun acc row ->
      let row_string = Array.fold row ~init:"" ~f:(fun acc cell ->
        Printf.sprintf "%s %s" acc cell.value
      ) in
      Printf.sprintf "%s%s\n" acc row_string
    )
  
  let next_candidate_coords ~(matrix: t) ~(step: int) (x, y) =
    if Int.equal (step % 2) 0
    then List.map ~f:(fun y -> (x, y)) (range (Array.length matrix))
    else List.map ~f:(fun x -> (x, y)) (range (Array.length matrix))
  
  let get_cell (matrix: t) (x, y) = Array.get (Array.get matrix y) x
end

module Path = struct
  type t =
    | Root
    | Path of { cell: BreachMatrix.cell; parent: t; }
  
  let rec unvisited path coord =
    match path with
    | Path { cell; _ } when Coord.equal cell.coord coord -> false
    | Path { parent; _ } -> unvisited parent coord
    | _ -> true
  
  let rec to_string = function
    | Root -> ""
    | Path { parent = Root; cell } -> Printf.sprintf "(%s) %s" (Coord.to_string cell.coord) cell.value
    | Path { parent; cell } -> Printf.sprintf "%s, (%s) %s" (to_string parent) (Coord.to_string cell.coord) cell.value
end

let rec work ~(matrix: BreachMatrix.t) ~(buffer_size: int) ~(step: int) ~(path: Path.t) ~(cell: BreachMatrix.cell) : Path.t List.t =
  (* If we have run out of buffer, return the path so far *)
  if step >= buffer_size then [path] else
  
  (* get the next possible coordinates to visit, filtering previously visited *)
  let candidates = BreachMatrix.next_candidate_coords ~matrix ~step cell.coord in
  let filtered_candidates = List.filter ~f:(Path.unvisited path) candidates in

  (* for each candiate coordinate, recurse to build up the possible paths *)
  List.bind filtered_candidates ~f:(fun coord ->
    let cell = BreachMatrix.get_cell matrix coord in
    let path = Path.Path { cell; parent = path } in
    work ~matrix ~buffer_size ~step:(step + 1) ~path ~cell
  )

let expand_paths ~(matrix: BreachMatrix.t) ~(buffer_size: int) : Path.t List.t =
  (* The first row needs some seed values before using the recursion worker fn *)
  let first_row = Array.get matrix 0 in
  List.bind (Array.to_list first_row) ~f:(fun cell ->
    let path = Path.Path { parent = Path.Root; cell } in
    work ~matrix ~buffer_size ~step:0 ~path ~cell
  )
