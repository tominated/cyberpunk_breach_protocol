open Base
open Lib.Breach_protocol

let example_matrix = BreachMatrix.of_list [
  ["1C" ; "BD" ; "55" ; "E9" ; "55"] ;
  ["1C" ; "BD" ; "1C" ; "55" ; "E9"] ;
  ["55" ; "E9" ; "E9" ; "BD" ; "BD"] ;
  ["55" ; "FF" ; "FF" ; "1C" ; "1C"] ;
  ["FF" ; "E9" ; "1C" ; "BD" ; "FF"] ;
]

let example_daemons: Daemon.t List.t = [
  { name = "datamine_v2"; breach_sequence = ["1C" ; "1C" ; "55" ] } ;
  { name = "datamine_v3"; breach_sequence = ["55" ; "FF" ; "1C" ] } ;
  { name = "copy_malware"; breach_sequence = ["BD" ; "E9" ; "BD" ; "55"] } ;
  { name = "crafting specs"; breach_sequence = ["55"; "1C" ; "FF" ; "BD"] }
]

let () =
  let buffer_size = 11 in
  Stdio.print_endline "Paths for matrix:";
  Stdio.print_endline (BreachMatrix.to_string example_matrix);
  Stdio.print_endline "For daemons:";
  Stdio.print_endline (String.concat ~sep:"\n" @@ List.map ~f:Daemon.to_string example_daemons);
  let paths = expand_paths ~matrix:example_matrix ~buffer_size ~daemons:example_daemons in
  let complete_paths = List.filter paths ~f:(Path.is_complete) in
  Stdio.printf "\ngiven buffer of %d\n" buffer_size;
  Stdio.printf "num paths: %d\n" (List.length paths);
  Stdio.printf "num complete paths: %d\n" (List.length complete_paths);
  List.iter ~f:(fun path -> Stdio.print_endline (Path.to_string path)) complete_paths
