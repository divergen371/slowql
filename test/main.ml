open Alcotest
open Slowql_lib

let test_fingerprint_numbers () =
  let input = "SELECT * FROM t WHERE id = 123" in
  let expected = "select * from t where id = ?" in
  check string "replace numbers" expected (Fingerprint.fingerprint input)

let test_fingerprint_strings () =
  let input = "SELECT * FROM t WHERE name = 'alice'" in
  let expected = "select * from t where name = ?" in
  check string "replace strings" expected (Fingerprint.fingerprint input)

let test_fingerprint_spaces () =
  let input = "SELECT  *   FROM    t" in
  let expected = "select * from t" in
  check string "normalize spaces" expected (Fingerprint.fingerprint input)

let test_stats_basic () =
  let values = [ 10.; 20.; 30. ] in
  let stats = Stats.compute_stats values in
  check int "count" 3 stats.count;
  check (float 0.001) "avg" 20.0 stats.avg;
  check (float 0.001) "max" 30.0 stats.max

let test_stats_percentiles () =
  (* 1..100 *)
  let values = List.init 100 (fun i -> float_of_int (i + 1)) in
  let stats = Stats.compute_stats values in
  check (float 0.001) "p50" 50.0 stats.p50;
  check (float 0.001) "p95" 95.0 stats.p95;
  check (float 0.001) "p99" 99.0 stats.p99

let () =
  run "Slowql"
    [
      ( "fingerprint",
        [
          test_case "numbers" `Quick test_fingerprint_numbers;
          test_case "strings" `Quick test_fingerprint_strings;
          test_case "spaces" `Quick test_fingerprint_spaces;
        ] );
      ( "stats",
        [
          test_case "basic" `Quick test_stats_basic;
          test_case "percentiles" `Quick test_stats_percentiles;
        ] );
    ]
