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

module Test = struct
  let coord = Alcotest.testable (Fmt.of_to_string Coord.to_string) Coord.equal

  module TestNextCandidateCoords = struct
    let matrix =
      of_list
        [ ["55"; "FF"; "1C"; "1C"; "BD"; "1C"; "1C"]
        ; ["BD"; "FF"; "55"; "55"; "BD"; "1C"; "55"]
        ; ["BD"; "1C"; "55"; "E9"; "7A"; "1C"; "E9"]
        ; ["55"; "7A"; "1C"; "FF"; "1C"; "55"; "FF"]
        ; ["55"; "E9"; "BD"; "1C"; "7A"; "E9"; "BD"]
        ; ["FF"; "7A"; "55"; "55"; "E9"; "BD"; "7A"]
        ; ["7A"; "1C"; "BD"; "7A"; "1C"; "7A"; "FF"] ]

    let vertical () =
      let candidate_coords = next_candidate_coords ~matrix ~step:2 (2, 2) in
      let expected : Coord.t List.t =
        [(2, 0); (2, 1); (2, 2); (2, 3); (2, 4); (2, 5); (2, 6)]
      in
      Alcotest.(check (list coord)) "vertical coords" expected candidate_coords

    let horizontal () =
      let candidate_coords = next_candidate_coords ~matrix ~step:3 (2, 2) in
      let expected : Coord.t List.t =
        [(0, 2); (1, 2); (2, 2); (3, 2); (4, 2); (5, 2); (6, 2)]
      in
      Alcotest.(check (list coord))
        "horizontal coords" expected candidate_coords

    let test () = vertical () ; horizontal ()

    let test_case = Alcotest.test_case "next_candidate_coords" `Quick test
  end

  let test_suite = [TestNextCandidateCoords.test_case]
end
