open Cmdliner
open Slowql_lib

type db = Auto | Postgres | MySQL

let db_conv =
  let parse = function
    | "auto" -> Ok Auto
    | "postgres" | "pgsql" -> Ok Postgres
    | "mysql" -> Ok MySQL
    | s -> Error (`Msg (Printf.sprintf "unknown db: %s" s))
  in
  let print ppf = function
    | Auto -> Format.fprintf ppf "auto"
    | Postgres -> Format.fprintf ppf "postgres"
    | MySQL -> Format.fprintf ppf "mysql"
  in
  Arg.conv (parse, print)

let run db files top json_out csv_out =
  Format.printf "db=%s, files=%s, top=%d@."
    (match db with Auto -> "auto" | MySQL -> "mysql" | Postgres -> "postgres")
    (String.concat "," files) top;
  Report.to_json_file ~path:json_out Stats.dummy;
  Report.to_csv_file ~path:csv_out Stats.dummy;
  ()

let db =
  let doc = "Target log format: auto, mysql, postgres." in
  Arg.(value & opt db_conv Auto & info [ "db" ] ~doc)

let files =
  let doc = "Input log files (.log or .gz)." in
  Arg.(non_empty & pos_all file [] & info [] ~docv:"FILES" ~doc)

let top =
  let doc = "Show top-N by total time." in
  Arg.(value & opt int 20 & info [ "top" ] ~doc)

let json_out =
  Arg.(
    value & opt string "slowql.json" & info [ "json" ] ~doc:"JSON output path")

let csv_out =
  Arg.(value & opt string "slowql.csv" & info [ "csv" ] ~doc:"CSV output path")

let cmd =
  let info =
    Cmd.info "slowql" ~doc:"SQL slow-query analyzer (OCaml; skeleton)"
  in
  Cmd.v info Term.(const run $ db $ files $ top $ json_out $ csv_out)

let () = Stdlib.exit (Cmd.eval cmd)
