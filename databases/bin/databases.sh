#!/bin/bash
set -eu

COMMANDS="create destroy mysql psql"
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
source $BASEDIR/bin/functions

ENVFILE=$BASEDIR/.env
SERVICE_MYSQL=mariadb
SERVICE_PGSQL=pgsql

# 作成
do_create() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $MYSQL_VOLUME || true
	docker volume rm $PGSQL_VOLUME || true
	volume_create $MYSQL_VOLUME
	volume_create $PGSQL_VOLUME
	mysql_init
	pgsql_init
	docker-compose down
}

# 破壊
do_destroy() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $MYSQL_VOLUME || true
	docker volume rm $PGSQL_VOLUME || true
	rm -f $ENVFILE
}

# mysql
do_mysql() {
	exec docker-compose exec mariadb mysql -p$MYSQL_ROOT_PASSWORD $@
}

# psql
do_psql() {
	exec docker-compose exec pgsql psql -U postgres $@
}

# 初期化
if [ ! -e "$ENVFILE" ]; then
	# デフォルト設定の書出
	cat > $ENVFILE << 'EOS'

# プロジェクト名
COMPOSE_PROJECT_NAME=database

# -- MySQL ---------------------

# Dockerイメージ
MYSQL_IMAGE=mariadb:10.4

# データボリューム
MYSQL_VOLUME=database-mariadb

# docker-compose Service名
MYSQL_SERVICE=mariadb

# Rootパスワード
MYSQL_ROOT_PASSWORD=

# DB設定1
MYSQL_1_DB=database1
MYSQL_1_USER=user1
MYSQL_1_PASSWORD=

# DB設定2
MYSQL_2_DB=database2
MYSQL_2_USER=user2
MYSQL_2_PASSWORD=

# -- PostgreSQL ----------------

# Dockerイメージ
PGSQL_IMAGE=postgres:11

# データボリューム
PGSQL_VOLUME=database-pgsql

# docker-compose Service名
PGSQL_SERVICE=pgsql

# postgresパスワード
PGSQL_POSTGRES_PASSWORD=

# DB設定1
PGSQL_1_DB=database3
PGSQL_1_USER=user3
PGSQL_1_PASSWORD=

# DB設定2
PGSQL_2_DB=database4
PGSQL_2_USER=user4
PGSQL_2_PASSWORD=

# DB設定3
PGSQL_3_DB=database5
PGSQL_3_USER=user5
PGSQL_3_PASSWORD=

EOS
fi

env_load
export COMPOSE_PROJECT_NAME
run $@

