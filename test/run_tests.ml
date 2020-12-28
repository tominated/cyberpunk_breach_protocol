let () =
  let open Alcotest in
  run "cyberpunk_breach_protocol"
    [ ("Lib.BreachResult", Lib.BreachResult.Test.test_suite)
    ; ("Lib.BreachMatrix", Lib.BreachMatrix.Test.test_suite)
    ; ("Lib.BreachProtocol", Lib.BreachProtocol.Test.test_suite) ]
