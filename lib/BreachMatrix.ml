open Base

type t = Cell.t Array.t Array.t

let range n = List.init n ~f:Fn.id

let of_list (list : string List.t List.t) : t =
  Array.of_list
  @@ List.mapi list ~f:(fun y row ->
         Array.of_list
         @@ List.mapi row ~f:(fun x value : Cell.t -> {coord= (x, y); value}) )

let to_string (matrix : t) =
  Array.fold matrix ~init:"" ~f:(fun acc row ->
      let row_string =
        Array.fold row ~init:"" ~f:(fun acc cell ->
            Printf.sprintf "%s %s" acc cell.value )
      in
      Printf.sprintf "%s%s\n" acc row_string )

let next_candidate_coords ~(matrix : t) ~(step : int) (x, y) : Coord.t List.t =
  if Int.equal (step % 2) 0 then
    List.map ~f:(fun y -> (x, y)) (range (Array.length matrix))
  else List.map ~f:(fun x -> (x, y)) (range (Array.length matrix))

let get_cell (matrix : t) (x, y) = matrix.(y).(x)
