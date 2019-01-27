#!/bin/bash
set -eu

case "${1:-}" in

	"root" )
		shift
		exec bash $@
		;;
	
	"app" )
		shift
		cd /home/node/app
		exec yarn run app
		;;

	* )
		echo "USAGE: [ root | app ]"
		exit 1
		;;
esac

