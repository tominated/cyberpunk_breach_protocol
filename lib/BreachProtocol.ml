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

module Test = struct
  module TestBestPath = struct
    let matrix =
      BreachMatrix.of_list
        [ ["1C"; "BD"; "55"; "E9"; "55"]
        ; ["1C"; "BD"; "1C"; "55"; "E9"]
        ; ["55"; "E9"; "E9"; "BD"; "BD"]
        ; ["55"; "FF"; "FF"; "1C"; "1C"]
        ; ["FF"; "E9"; "1C"; "BD"; "FF"] ]

    let copy_malware_daemon : Daemon.t =
      {name= "copy_malware"; breach_sequence= ["BD"; "E9"; "BD"; "55"]; score= 3}

    let crafting_specs_daemon : Daemon.t =
      { name= "crafting specs"
      ; breach_sequence= ["55"; "1C"; "FF"; "BD"]
      ; score= 4 }

    let daemons : Daemon.t List.t =
      [ {name= "datamine_v2"; breach_sequence= ["1C"; "1C"; "55"]; score= 1}
      ; {name= "datamine_v3"; breach_sequence= ["55"; "FF"; "1C"]; score= 2}
      ; copy_malware_daemon
      ; crafting_specs_daemon ]

    let buffer_size = 8

    let path : Path.t =
      [ {coord= (1, 0); value= "BD"}
      ; {coord= (1, 2); value= "E9"}
      ; {coord= (3, 2); value= "BD"}
      ; {coord= (3, 1); value= "55"}
      ; {coord= (0, 1); value= "1C"}
      ; {coord= (0, 4); value= "FF"}
      ; {coord= (3, 4); value= "BD"} ]

    let completed_daemons = [copy_malware_daemon; crafting_specs_daemon]

    (* This is the matrix & optimal path for the spellbound quest in-game, as
       found here: https://gamerjournalist.com/how-to-complete-spellbound-and-decrypt-the-book-of-spells-in-cyberpunk-2077/ *)
    let spellbound_quest_path () =
      let expected : BreachResult.t Option.t = Some {path; completed_daemons} in
      let best_path = best_path ~matrix ~buffer_size ~daemons in
      Alcotest.(check (option BreachResult.Test.breach_result))
        "spellbound quest path" expected best_path

    let test_case = Alcotest.test_case "best_path" `Slow spellbound_quest_path
  end

  let test_suite = [TestBestPath.test_case]
end
