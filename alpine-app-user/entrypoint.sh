#!/bin/sh
set -eu

case "${1:-}" in

	"root" )
		shift
		exec ash $@
		;;
	
	"app" )
		shift
		exec su-exec app ash $@
		;;

	* )
		echo "USAGE: [ root | app ]"
		exit 1
		;;
esac

