#!/bin/sh

set -e

# Allow overriding with environment variables.
OCAMLBUILD=${OCAMLBUILD:-ocamlbuild}
OCBFLAGS=${OCAMLFLAGS:-}
OCAMLFIND=${OCAMLFIND:-ocamlfind}

ocb()
{
    $OCAMLBUILD $OCBFLAGS $*
}

ocf()
{
    $OCAMLFIND $*
}

rule()
{
    case $1 in
        clean  ) ocb -clean ;;
        all    ) ocb libalpm.cma libalpm.cmxa ;;
        install)
            rule all
            ocf install alpm META \
                _build/{libalpm.{a,cmxa,cma},Alpm.cm{i,o,x}}
            ;;
        *) echo "Unknown action: $1" ;;
    esac
}

if [ $# -eq 0 ] ; then
    rule all
else
    while [ $# -gt 0 ] ; do
        rule $1
        shift
    done
fi
