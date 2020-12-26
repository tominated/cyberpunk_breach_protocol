open Base
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

module Daemon = struct
  type t = { name : string ; breach_sequence : string List.t }

  let to_string {name; breach_sequence} =
    Printf.sprintf "%s %s" name (String.concat ~sep:" " breach_sequence)
end

module DaemonProgress = struct
  type t =
    | Incomplete of { daemon: Daemon.t; sequence_left: string List.t }
    | Complete of { daemon: Daemon.t }
    | Impossible of {daemon: Daemon.t }
  
  let of_daemon (daemon: Daemon.t) = Incomplete { daemon; sequence_left = daemon.breach_sequence }

  let step ~(value: string) ~(buffer_left: int) (daemon_progress: t) : t =
    match daemon_progress with
    | Complete _ | Impossible _ -> daemon_progress
    | Incomplete progress -> begin
      match (progress.sequence_left, progress.daemon.breach_sequence) with
        (* Not enough room in the buffer to complete *)
        | sequence_left, _ when List.length sequence_left > buffer_left ->
            Impossible { daemon = progress.daemon }  
      
        (* The daemon has been activated *)
        | [], _ -> Complete { daemon = progress.daemon }
        | head :: [], _ when String.equal head value ->
            Complete { daemon = progress.daemon }

        (* We hit the next value in the sequence left to process *)
        | head :: sequence_left, _ when String.equal head value ->
            Incomplete { progress with sequence_left }
        
        (* We didn't get the next value, but we got the first value, so reset from there *)
        | _, head :: sequence_left when String.equal head value ->
            Incomplete { progress with sequence_left }
        
        (* No value match, reset progress *)
        | _ -> Incomplete { progress with sequence_left = progress.daemon.breach_sequence }
    end
  
  let is_done = function
    | Complete _ | Impossible _ -> true
    | _ -> false
  
  let is_complete = function
    | Complete _ -> true
    | _ -> false
end

module Path = struct
  type t =
    | Root
    | Path of { cell: BreachMatrix.cell; parent: t; daemons: DaemonProgress.t List.t }
  
  let rec unvisited path coord =
    match path with
    | Path { cell; _ } when Coord.equal cell.coord coord -> false
    | Path { parent; _ } -> unvisited parent coord
    | _ -> true
  
  let rec to_string = function
    | Root -> ""
    | Path { parent = Root; cell; _ } -> Printf.sprintf "(%s) %s" (Coord.to_string cell.coord) cell.value
    | Path { parent; cell; _ } -> Printf.sprintf "%s, (%s) %s" (to_string parent) (Coord.to_string cell.coord) cell.value

  (* Step the progress of a daemon with the current value in the path *)
 
  let step_daemons_progress ~value ~path ~buffer_left =
    match path with
    | Root -> Root
    | Path {cell;parent;daemons} -> Path {cell; parent; daemons = List.map daemons ~f:(DaemonProgress.step ~value ~buffer_left)}

  (* Returns true if all daemons are complete or impossible *)
  let is_done = function
    | Root -> false
    | Path { daemons; _} -> List.for_all daemons ~f:(DaemonProgress.is_done)

  let completed_daemons = function
    | Root -> []
    | Path { daemons; _ } -> List.filter_map daemons ~f:(function Complete {daemon} -> Some daemon | _ -> None)

  let is_complete = function
    | Root -> false
    | Path { daemons; _} -> List.for_all daemons ~f:(DaemonProgress.is_complete)

  let top_level_path ~cell ~daemons =
    let daemons = List.map daemons ~f:DaemonProgress.of_daemon in
    Path { parent = Root; cell; daemons }
end


let rec work ~(matrix: BreachMatrix.t) ~(buffer_size: int) ~(step: int) ~(path: Path.t) ~(cell: BreachMatrix.cell) : Path.t List.t =
  (* If we have run out of buffer, return the path so far *)
  if step >= buffer_size then [path] else
  
  let path = Path.step_daemons_progress ~value:cell.value ~path ~buffer_left:(buffer_size - step) in
  if Path.is_done path then [path] else

  (* get the next possible coordinates to visit, filtering previously visited *)
  let candidates = BreachMatrix.next_candidate_coords ~matrix ~step cell.coord in
  let filtered_candidates = List.filter ~f:(Path.unvisited path) candidates in

  (* for each candiate coordinate, recurse to build up the possible paths *)
  List.bind filtered_candidates ~f:(fun coord ->
    let cell = BreachMatrix.get_cell matrix coord in
    let path = match path with 
      | Path {daemons; _} -> Path.Path { cell; parent = path; daemons }
      (* this shouldn't happen... *)
      | Root -> Path.Path { cell; parent = path; daemons = [] }
    in
    work ~matrix ~buffer_size ~step:(step + 1) ~path ~cell
  )

let expand_paths ~(matrix: BreachMatrix.t) ~(buffer_size: int) ~(daemons: Daemon.t List.t) : Path.t List.t =
  (* The first row needs some seed values before using the recursion worker fn *)
  let first_row = Array.get matrix 0 in
  List.bind (Array.to_list first_row) ~f:(fun cell ->
    let path = Path.top_level_path ~cell ~daemons in
    work ~matrix ~buffer_size ~step:0 ~path ~cell
  )
