let to_json_file ~path (_rows : Stats.row list) =
  let oc = open_out path in
  output_string oc "[]\n";
  close_out oc

let to_csv_file ~path (_rows : Stats.row list) =
  let oc = open_out path in
  output_string oc "fingerprint,example,count,total,avg,max,p50,p95,p99\n";
  close_out oc
