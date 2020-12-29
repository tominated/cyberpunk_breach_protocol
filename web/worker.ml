open Js_of_ocaml

let () = Worker.set_onmessage Web_lib.Worker.on_message
