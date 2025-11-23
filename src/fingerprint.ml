let re_num = Re.compile (Re.Perl.re "\\d+")
let re_str = Re.compile (Re.Perl.re "'[^']*'")
let re_space = Re.compile (Re.Perl.re "\\s+")

let fingerprint s =
  let s = String.lowercase_ascii s in
  let s = Re.replace_string re_num ~by:"?" s in
  let s = Re.replace_string re_str ~by:"?" s in
  let s = Re.replace_string re_space ~by:" " s in
  String.trim s
