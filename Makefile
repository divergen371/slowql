.PHONY: build test clean fmt

build:
	./scripts/opam-dune build

test:
	./scripts/opam-dune runtest

clean:
	./scripts/opam-dune clean

fmt:
	opam exec -- ocamlformat -i $$(git ls-files '*.ml' '*.mli')


