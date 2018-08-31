#!/bin/bash
set -eu

function server_start {
	echo "SERVICE START"
	service rsyslog start
	service postfix start
	sleep infinity & wait
}

function server_stop {
	echo ""
	trap - INT EXIT INT TERM
	echo "SERVICE STOP"
	service postfix stop
	service rsyslog stop
	exit 0
}

case "${1:-}" in

	"run" )
		trap server_stop INT EXIT INT TERM
		server_start
		;;

	"root" )
		shift
		exec bash $@
		;;
	
	* )
		echo "USAGE: [ run | root ]"
		exit 1
		;;
esac

