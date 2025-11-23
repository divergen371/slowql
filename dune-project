(lang dune 3.20)

(name slowql)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name slowql)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  (ocaml
   (>= 5.2.0))
  (alcotest :with-test)
  (ocamlformat :build)
  re
  yojson
  csv
  decompress
  caqti
  caqti-lwt
  cohttp-lwt-unix
  logs
  lwt
  ptime
  tyxml
  digestif
  notty)
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
