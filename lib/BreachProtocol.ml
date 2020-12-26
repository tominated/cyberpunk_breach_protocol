open Base

let range n = List.init n ~f:Fn.id

module Coord = struct
  type t = int * int

  let equal (x1, y1) (x2, y2) = Int.equal x1 x2 && Int.equal y1 y2

  let to_string (x, y) = Printf.sprintf "(%d, %d)" x y
end

module Cell = struct
  type t = {coord: Coord.t; value: string}

  let to_string {coord; value} =
    Printf.sprintf "%s %s" (Coord.to_string coord) value
end

module BreachMatrix = struct
  type t = Cell.t Array.t Array.t

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

  let next_candidate_coords ~(matrix : t) ~(step : int) (x, y) : Coord.t List.t
      =
    if Int.equal (step % 2) 0 then
      List.map ~f:(fun y -> (x, y)) (range (Array.length matrix))
    else List.map ~f:(fun x -> (x, y)) (range (Array.length matrix))

  let get_cell (matrix : t) (x, y) = matrix.(y).(x)
end

module Daemon = struct
  type t = {name: string; breach_sequence: string List.t; score: int}

  let to_string {name; breach_sequence; score} =
    Printf.sprintf "%s %s - score: %d" name
      (String.concat ~sep:" " breach_sequence)
      score
end

module DaemonProgress = struct
  type t = {daemon: Daemon.t; sequence_left: string List.t}

  let of_daemon (daemon : Daemon.t) =
    {daemon; sequence_left= daemon.breach_sequence}

  let step ~(value : string) ~(buffer_left : int) (progress : t) : t =
    match (progress.sequence_left, progress.daemon.breach_sequence) with
    (* Not enough room in the buffer to complete, just bail *)
    | sequence_left, _ when List.length sequence_left > buffer_left ->
        progress
    (* The daemon has been activated *)
    | [], _ ->
        progress
    (* We hit the next value in the sequence left to process *)
    | head :: sequence_left, _ when String.equal head value ->
        {progress with sequence_left}
    (* We didn't get the next value, but we got the first value, so reset from there *)
    | _, head :: sequence_left when String.equal head value ->
        {progress with sequence_left}
    (* No value match, reset progress *)
    | _ ->
        {progress with sequence_left= progress.daemon.breach_sequence}

  let step_all ~value ~buffer_left = List.map ~f:(step ~value ~buffer_left)

  let is_done ~buffer_left {sequence_left; _} =
    match sequence_left with
    | [] ->
        true
    | incomplete ->
        List.length incomplete > buffer_left

  let all_done ~buffer_left = List.for_all ~f:(is_done ~buffer_left)

  let is_complete {sequence_left; _} = List.is_empty sequence_left

  let get_complete_daemon progress =
    if is_complete progress then Some progress.daemon else None

  let score {sequence_left; daemon} =
    match sequence_left with [] -> daemon.score | _ -> 0

  let total_score = List.fold ~init:0 ~f:(fun acc dp -> acc + score dp)
end

module Path = struct
  type t = Cell.t List.t

  let unvisited (path : t) (coord : Coord.t) =
    not @@ List.exists path ~f:(fun cell -> Coord.equal cell.coord coord)

  let to_string (path : t) =
    String.concat ~sep:"," (List.map ~f:Cell.to_string path)

  (* Returns true if all daemons are complete or impossible *)
end

module BreachResult = struct
  type t = {path: Path.t; completed_daemons: Daemon.t List.t}

  let score result =
    List.fold result.completed_daemons ~init:0 ~f:(fun acc d -> acc + d.score)

  let mk ~path ~daemons_progress =
    let completed_daemons =
      List.filter_map daemons_progress ~f:DaemonProgress.get_complete_daemon
    in
    {path; completed_daemons}

  let compare a b =
    match Int.compare (score a) (score b) with
    | 0 ->
        Int.compare
          (List.length a.completed_daemons)
          (List.length b.completed_daemons)
    | x ->
        x

  let best_of a b = match compare a b with -1 -> b | _ -> a

  let best_of_option a b =
    match (a, b) with
    | r, None | None, r ->
        r
    | Some a, Some b ->
        Some (best_of a b)
end

let rec work ~(matrix : BreachMatrix.t) ~(buffer_size : int) ~(step : int)
    ~(path : Path.t) ~(cell : Cell.t)
    ~(daemons_progress : DaemonProgress.t List.t) : BreachResult.t Option.t =
  (* If we have run out of buffer, return the path so far *)
  if step >= buffer_size then Some (BreachResult.mk ~path ~daemons_progress)
  else
    let buffer_left = buffer_size - step in
    let path = cell :: path in
    let daemons_progress =
      DaemonProgress.step_all ~value:cell.value ~buffer_left daemons_progress
    in
    if DaemonProgress.all_done ~buffer_left daemons_progress then
      Some (BreachResult.mk ~path ~daemons_progress)
    else
      (* get the next possible coordinates to visit, filtering previously visited *)
      let candidates =
        BreachMatrix.next_candidate_coords ~matrix ~step cell.coord
        |> List.filter ~f:(Path.unvisited path)
      in
      (* for each candiate coordinate, recurse to build up a path until a possible result is found *)
      List.fold candidates ~init:None ~f:(fun prev_best coord ->
          let cell = BreachMatrix.get_cell matrix coord in
          let result =
            work ~matrix ~buffer_size ~step:(step + 1) ~path ~cell
              ~daemons_progress
          in
          BreachResult.best_of_option prev_best result )

let best_path ~(matrix : BreachMatrix.t) ~(buffer_size : int)
    ~(daemons : Daemon.t List.t) : BreachResult.t Option.t =
  let daemons_progress = List.map daemons ~f:DaemonProgress.of_daemon in
  Array.fold matrix.(0) ~init:None ~f:(fun prev_result cell ->
      let next_result =
        work ~matrix ~buffer_size ~step:0 ~path:[] ~cell ~daemons_progress
      in
      BreachResult.best_of_option prev_result next_result )
