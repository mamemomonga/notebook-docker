#!/bin/bash
set -eu
COMMANDS="create destroy psql export import"
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
source $BASEDIR/bin/functions

ENVFILE=$BASEDIR/.env

# 作成
do_create() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $PGSQL_VOLUME || true
	volume_create $PGSQL_VOLUME
	pgsql_init
	docker-compose down
}

# 破壊
do_destroy() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $PGSQL_VOLUME || true
}

# psql
do_psql() {
	exec docker-compose exec $PGSQL_SERVICE psql -U postgres $@
}


# エクスポート
do_export() {
	local dbid=$1
	local filename=$2
	local dbname=$( eval 'echo $PGSQL_'$dbid'_DB' )
	docker-compose exec $PGSQL_SERVICE pg_dump -U postgres $dbname > $filename
	echo "$filename をエクスポートしました"
}

# インポート
do_import() {
	local dbid=$1
	local filename=$2
	local dbname=$( eval 'echo $PGSQL_'$dbid'_DB' )
	PGSQL_CONTAINER=$( docker-compose ps -q $PGSQL_SERVICE )

	docker exec -i $PGSQL_CONTAINER psql -U postgres $dbname << 'EOS'
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
EOS
	docker exec -i $PGSQL_CONTAINER psql -U postgres $dbname < $filename
	echo "$filename をインポートしました"
}

pgsql_init() {
	password_generate PGSQL_POSTGRES_PASSWORD

	CURRENT_CONTAINER=$(
	docker run -d --rm \
		-v $PGSQL_VOLUME:/var/lib/postgresql/data \
		-v $BASEDIR/etc/postgresql.conf:/etc/postgresql/postgresql.conf:ro \
		-e "POSTGRES_PASSWORD=$PGSQL_POSTGRES_PASSWORD" \
		$PGSQL_IMAGE
	)

	perl - $CURRENT_CONTAINER << 'EOS'
use strict; $|=1;
my $kid=open(my $log,"docker logs -f $ARGV[0] 2>&1 | ") || die $!;
while(<$log>) {
	print "$_";
	if(m#\QPostgreSQL init process complete; ready for start up.\E#s ){
		kill 2,$kid;
		print "初期化を確認しました\n";
		exit(0);
	}
	if(m#\Q[ERROR]\E#s ){
		kill 2,$kid;
		print "初期化に失敗しました\n";
		exit(1);
	}
}
EOS
	create_db_users pgsql_create_db_user PGSQL
	docker rm -f $CURRENT_CONTAINER
}
pgsql_create_db_user() {
	local num=$1
	local db=$2
	local user=$3
	local password=$4
	if [ -z "$password" ]; then
		password_generate 'PGSQL_'$i'_PASSWORD'
		password=$( eval 'echo "$PGSQL_'$i'_PASSWORD"')
	fi
	docker exec -i $CURRENT_CONTAINER psql -U postgres << EOS
CREATE DATABASE $db;
CREATE USER $user WITH ENCRYPTED PASSWORD '$password';
GRANT ALL PRIVILEGES ON DATABASE $db TO $user;
EOS
}

if [ ! -e "$ENVFILE" ]; then
	cp $BASEDIR/default.env $ENVFILE
fi
env_load

export COMPOSE_PROJECT_NAME
run $@


