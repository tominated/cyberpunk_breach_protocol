open Base

let rec work ~matrix ~buffer_size ~step ~path ~cell ~daemons_progress =
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

let best_path ~matrix ~buffer_size ~daemons =
  let daemons_progress = List.map daemons ~f:DaemonProgress.of_daemon in
  Array.fold matrix.(0) ~init:None ~f:(fun prev_result cell ->
      let next_result =
        work ~matrix ~buffer_size ~step:0 ~path:[] ~cell ~daemons_progress
      in
      BreachResult.best_of_option prev_result next_result )
