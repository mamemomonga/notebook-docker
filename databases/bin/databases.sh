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
	docker-compose down || true
	docker volume rm $COMPOSE_PROJECT_NAME'-'$SERVICE_MYSQL || true
	docker volume rm $COMPOSE_PROJECT_NAME'-'$SERVICE_PGSQL || true
	volume_create $COMPOSE_PROJECT_NAME'-'$SERVICE_MYSQL
	volume_create $COMPOSE_PROJECT_NAME'-'$SERVICE_PGSQL
	mysql_init
	pgsql_init
	docker-compose down
}

# 破壊
do_destroy() {
	docker-compose down || true
	docker volume rm $COMPOSE_PROJECT_NAME'-'$SERVICE_MYSQL || true
	docker volume rm $COMPOSE_PROJECT_NAME'-'$SERVICE_PGSQL || true
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
# postgresパスワード
PGSQL_POSTGRES_PASSWORD=

# DB設定1
PGSQL_1_DB=database3
PGSQL_1_USER=user3
PGSQL_1_PASSWORD=

EOS
fi

env_load
export COMPOSE_PROJECT_NAME
run $@

