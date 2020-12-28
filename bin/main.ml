open Base
open Lib

let example_matrix =
  BreachMatrix.of_list
    [ ["1C"; "BD"; "55"; "E9"; "55"]
    ; ["1C"; "BD"; "1C"; "55"; "E9"]
    ; ["55"; "E9"; "E9"; "BD"; "BD"]
    ; ["55"; "FF"; "FF"; "1C"; "1C"]
    ; ["FF"; "E9"; "1C"; "BD"; "FF"] ]

let example_daemons : Daemon.t List.t =
  [ {name= "datamine_v2"; breach_sequence= ["1C"; "1C"; "55"]; score= 1}
  ; {name= "datamine_v3"; breach_sequence= ["55"; "FF"; "1C"]; score= 2}
  ; {name= "copy_malware"; breach_sequence= ["BD"; "E9"; "BD"; "55"]; score= 3}
  ; {name= "crafting specs"; breach_sequence= ["55"; "1C"; "FF"; "BD"]; score= 4}
  ]

let () =
  let buffer_size = 8 in
  Stdio.print_endline "Paths for matrix:" ;
  Stdio.print_endline (BreachMatrix.to_string example_matrix) ;
  Stdio.print_endline "For daemons:" ;
  Stdio.print_endline
    (String.concat ~sep:"\n" @@ List.map ~f:Daemon.to_string example_daemons) ;
  let best_path =
    BreachProtocol.best_path ~matrix:example_matrix ~buffer_size
      ~daemons:example_daemons
  in
  Stdio.printf "\ngiven buffer of %d\n" buffer_size ;
  Option.iter best_path ~f:(fun {path; completed_daemons} ->
      let daemon_names =
        List.map completed_daemons ~f:Daemon.to_string
        |> String.concat ~sep:"\n"
      in
      Stdio.printf "top path: %s\n\n" (Path.to_string path) ;
      Stdio.print_endline "executes daemons:" ;
      Stdio.print_endline daemon_names )
