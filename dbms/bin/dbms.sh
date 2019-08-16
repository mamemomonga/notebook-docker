#!/bin/bash
set -eu
COMMANDS="mysql_create pgsql_create mysql_destroy pgsql_destroy mysql psql"
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
source $BASEDIR/bin/functions

ENVFILE=$BASEDIR/.env

do_mysql_create() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $MYSQL_VOLUME || true
	volume_create $MYSQL_VOLUME
	mysql_init
	docker-compose down
}

do_pgsql_create() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $PGSQL_VOLUME || true
	volume_create $PGSQL_VOLUME
	pgsql_init
	docker-compose down
}

do_mysql_destroy() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $MYSQL_VOLUME || true
}

do_pgsql_destroy() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $PGSQL_VOLUME || true
}

do_mysql() {
	exec docker-compose exec $MYSQL_SERVICE mysql -p$MYSQL_ROOT_PASSWORD $@
}

# psql
do_psql() {
	exec docker-compose exec $PGSQL_SERVICE psql -U postgres $@
}

# 初期化
if [ ! -e "$ENVFILE" ]; then
	cp $BASEDIR/default.env $ENVFILE
fi
env_load

export COMPOSE_PROJECT_NAME
run $@

