#!/bin/bash
set -eu
COMMANDS="create destroy mysql export import"
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
source $BASEDIR/bin/functions

ENVFILE=$BASEDIR/.env

# 作成
do_create() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $MYSQL_VOLUME || true
	volume_create $MYSQL_VOLUME
	mysql_init
	docker-compose down
}

# 破壊
do_destroy() {
	if [ -e $ENVFILE ]; then
		docker-compose down || true
	fi
	docker volume rm $MYSQL_VOLUME || true
}

# mysql
do_mysql() {
	exec docker-compose exec $MYSQL_SERVICE mysql -p$MYSQL_ROOT_PASSWORD $@
}


# エクスポート
do_export() {
	local dbid=$1
	local filename=$2
	local dbname=$( eval 'echo $MYSQL_'$dbid'_DB' )
	mysql_enable_root
	docker-compose exec $MYSQL_SERVICE mysqldump $dbname > $filename
	mysql_disable_root
	echo "$filename をエクスポートしました"
}

# インポート
do_import() {
	local dbid=$1
	local filename=$2
	local dbname=$( eval 'echo $MYSQL_'$dbid'_DB' )
	mysql_enable_root
	MYSQL_CONTAINER=$( docker-compose ps -q $MYSQL_SERVICE )
	docker exec $MYSQL_CONTAINER bash -c "mysqldump --add-drop-table --no-data $dbname | grep 'DROP TABLE' | mysql $dbname"
	docker exec -i $MYSQL_CONTAINER mysql $dbname < $filename
	mysql_disable_root
	echo "$filename をインポートしました"
}

# 初期化
mysql_init() {
	password_generate MYSQL_ROOT_PASSWORD
	CURRENT_CONTAINER=$(
	docker run -d --rm \
		-v $MYSQL_VOLUME:/var/lib/mysql \
		-v $BASEDIR/etc/mysqld/my.cnf:/etc/mysql/conf.d/my.cnf \
		-e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
		$MYSQL_IMAGE
	)

	# 初期化を待つ
	perl - $CURRENT_CONTAINER << 'EOS'
use strict; $|=1;
my $kid=open(my $log,"docker logs -f $ARGV[0] 2>&1 | ") || die $!;
my $count=0;
while(<$log>) {
	print "$_";
	if(m#\Qready for connections.\E#s ){
		$count++;
		if($count==2) {
			kill 2,$kid;
			print "初期化を確認しました\n";
			exit(0);
		}
	}
	if(m#\Q[ERROR]\E#s ){
		kill 2,$kid;
		print "初期化に失敗しました\n";
		exit(1);
	}
}
EOS

	# rootで実行できるようにする
	docker exec -i $CURRENT_CONTAINER bash << EOS
cat > /root/.my.cnf << EOL
[client]
user=root
password=$MYSQL_ROOT_PASSWORD
EOL
chmod 600 /root/.my.cnf
EOS

	create_db_users mysql_create_db_user MYSQL

	# コンテナ削除
	docker rm -f $CURRENT_CONTAINER
}

# データベースとユーザの作成
mysql_create_db_user() {
	local num=$1
	local db=$2
	local user=$3
	local password=$4
	if [ -z "$password" ]; then
		password_generate 'MYSQL_'$i'_PASSWORD'
		password=$( eval 'echo "$MYSQL_'$i'_PASSWORD"')
	fi
	docker exec -i $CURRENT_CONTAINER mysql -v << EOS
CREATE DATABASE $db default character set utf8mb4;
GRANT ALTER,CREATE,DELETE,DROP,INDEX,INSERT,SELECT,UPDATE
  ON $db.* TO $user@'%'
  IDENTIFIED BY '$password';
EOS
}

# rootでのコマンド実行有効化
mysql_enable_root() {
	docker exec -i $( docker-compose ps -q $MYSQL_SERVICE ) bash << EOS
cat > /root/.my.cnf << EOL
[client]
user=root
password=$MYSQL_ROOT_PASSWORD
EOL
chmod 600 /root/.my.cnf
EOS
}

# rootでのコマンド実行無効化
mysql_disable_root() {
	docker-compose exec $MYSQL_SERVICE rm -f /root/.my.cnf
}

# 設定読込
if [ ! -e "$ENVFILE" ]; then
	cp $BASEDIR/default.env $ENVFILE
fi
env_load

export COMPOSE_PROJECT_NAME
run $@

