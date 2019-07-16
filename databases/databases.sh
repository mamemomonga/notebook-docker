#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd . && pwd )"
ENVFILE=$BASEDIR/.env
eval $( cat $ENVFILE | perl -nlpE 's#^([^=]+)=(.+)$#export $1="$2"#' )

# ボリュームの作成
volume_create() {
	local name=$1
	if [ -n "$( docker volume ls -q | grep $name )" ]; then
		echo "Volume: $name already exists."
		exit 1
	fi
	docker volume create $name
}

# パスワードの作成
create_password() {
	local name=$1
	local fn="$BASEDIR/.password-$name"
	if [ -e "$fn" ]; then
		echo "$fn already exists."
		exit 1
	fi
	perl -E 'my @chars; for(my $i=0;$i<$ARGV[1];$i++) { push @chars,substr($ARGV[0],int(rand()*length($ARGV[0])),1) }; say join("",@chars);' 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789-_().!' 16 > $fn
	chmod 600 $fn
	echo "Create: $fn"
}

# MariaDBの初期化
init_mariadb() {
	create_password mariadb
	local password=$(cat $BASEDIR/.password-mariadb)
	docker-compose run -e MYSQL_ROOT_PASSWORD="$password" -d mariadb
	local container=$(docker-compose ps -q mariadb)
	perl - $container << 'EOS'
use strict;
$|=1;
my $kid=open(my $log,"docker logs -f $ARGV[0] 2>&1 | ") || die $!;
while(<$log>) {
	if(m#\Qready for connections.\E#s ){
		kill 2,$kid;
		print "起動を確認しました\n";
		exit(0);
	}
	if(m#\Q[ERROR]\E#s ){
		kill 2,$kid;
		print "初期化に失敗しました\n";
		exit(1);
	}
	print "$_"
}
EOS
}

# PostgreSQLの初期化
init_pgsql() {
	create_password pgsql
	local password=$(cat $BASEDIR/.password-pgsql)
	docker-compose run -e POSTGRES_PASSWORD="$password" -d pgsql
	local container=$(docker-compose ps -q pgsql)
	perl - $container << 'EOS'
use strict;
$|=1;
my $kid=open(my $log,"docker logs -f $ARGV[0] 2>&1 | ") || die $!;
while(<$log>) {
	if(m#\QPostgreSQL init process complete; ready for start up.\E#s ){
		kill 2,$kid;
		print "起動を確認しました\n";
		exit(0);
	}
	if(m#\Q[ERROR]\E#s ){
		kill 2,$kid;
		print "初期化に失敗しました\n";
		exit(1);
	}
	print "$_"
}
EOS
}

# 破壊
destroy() {
	docker-compose down || true
	docker volume rm $COMPOSE_PROJECT_NAME'-mariadb' || true
	docker volume rm $COMPOSE_PROJECT_NAME'-pgsql' || true
	rm -f $BASEDIR/.password-mariadb
	rm -f $BASEDIR/.password-pgsql
}

do_create() {
	destroy
	volume_create $COMPOSE_PROJECT_NAME'-mariadb'
	volume_create $COMPOSE_PROJECT_NAME'-pgsql'
	init_mariadb
	init_pgsql
	docker-compose down
}

do_destroy() {
	destory
}

COMMANDS="create destroy"

function run {

    for i in $COMMANDS; do
    if [ "$i" == "${1:-}" ]; then
        shift
        do_$i $@
        exit 0
    fi
    done
    echo "USAGE: $( basename $0 ) COMMAND"
    echo "COMMANDS:"
    for i in $COMMANDS; do
    echo "   $i"
    done
    exit 1
}

run $@

