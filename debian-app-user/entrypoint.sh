#!/bin/bash
set -eu

case "${1:-}" in

	"root" )
		shift
		exec bash $@
		;;
	
	"app" )
		shift
		exec gosu app bash $@
		;;

	* )
		echo "USAGE: [ root | app ]"
		exit 1
		;;
esac

