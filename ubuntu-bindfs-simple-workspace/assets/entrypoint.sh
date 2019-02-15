#!/bin/bash
set -eu

case "${1:-}" in

	"root" )
		shift
		cd /root
		exec bash $@
		;;
	
	"app" )
		shift
		cd /home/app
		exec gosu app bash $@
		;;

	"expand-app-skel" )
		exec tar cC /home/app-skel .
		;;

	* )
		echo "USAGE: [ root | app ]"
		exit 1
		;;
esac

