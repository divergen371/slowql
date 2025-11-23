type row = {
  fingerprint : string;
  example : string;
  count : int;
  total : float;
  min : float;
  avg : float;
  max : float;
  p1 : float;
  p50 : float;
  p95 : float;
  p99 : float;
  std : float;
}

let dummy = []

let compute_stats values =
  let n = List.length values in
  let sorted = List.sort Float.compare values in
  let sum = List.fold_left ( +. ) 0. sorted in
  let avg = if n > 0 then sum /. float_of_int n else 0. in
  let min_val = if n > 0 then List.nth sorted 0 else 0. in
  let max_val = if n > 0 then List.nth sorted (n - 1) else 0. in
  let percentile p =
    if n = 0 then 0.
    else
      let k = int_of_float (ceil (float_of_int n *. p)) - 1 in
      let k = if k < 0 then 0 else if k >= n then n - 1 else k in
      List.nth sorted k
  in
  let std =
    if n <= 1 then 0.
    else
      let variance_sum =
        List.fold_left (fun acc v -> acc +. ((v -. avg) ** 2.)) 0. sorted
      in
      sqrt (variance_sum /. float_of_int n)
  in
  {
    fingerprint = "";
    example = "";
    count = n;
    total = sum;
    min = min_val;
    avg;
    max = max_val;
    p1 = percentile 0.01;
    p50 = percentile 0.50;
    p95 = percentile 0.95;
    p99 = percentile 0.99;
    std;
  }
