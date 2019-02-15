#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -e "$BASEDIR/config" ]; then
	cat > "$BASEDIR/config" << 'EOS'
NAME="ubuntu-bindfs-simple-workspace"
IMAGE_NAME="$NAME:latest"
CONTAINER_NAME=$NAME"_1"
EOS
fi

source $BASEDIR/config

VOL_NAME=$CONTAINER_NAME
VOL_MOUNT="$(pwd)/home/app"

before_start() {

	# bindfsプラグインがなければインストールする
	if [ -z $(docker plugin ls --format '{{.Name}}' | grep 'lebokus/bindfs') ]; then
		echo "Install docker plugin lebokus/bindfs"
		docker plugin install lebokus/bindfs
	fi

	# bindfsプラグインが無効ならば有効にする
	if [ $(docker plugin ls --format '{{.Name}} {{.Enabled}}' | grep lebokus/bindfs:latest | awk '{print $2}') == "false" ]; then
		echo "Set Enable plugin lebokus/bindfs"
		docker plugin enable lebokus/bindfs
	fi

	#  Dockerが動作しているカーネルとローカルのカーネルが同じ
	if [ "$(docker info --format '{{.KernelVersion}}')" == "$(uname -r)" ]; then
		# おそらくLinuxである
	
		# UID,GIDをそれぞれ1000, ローカルユーザ・グループにマッピングした
		# ボリュームの作成
		docker volume create \
		    -d lebokus/bindfs \
		    -o sourcePath=$VOL_MOUNT \
		    -o map=$(id -u)/10000:@$(id -g)/@10000 \
			$VOL_NAME > /dev/null
	else
		# おそらくDocker for Macなどである
		# UID,GIDをそれぞれ0(root)にマッピングした
		# ボリュームの作成
		docker volume create \
		    -d lebokus/bindfs \
		    -o sourcePath=$VOL_MOUNT \
		    -o map=0/10000:@0/@10000 \
			$VOL_NAME > /dev/null
	fi
}

after_stop() {
	# ボリューム削除
	if [ -n "$(docker volume ls --format='{{.Name}}' | grep $VOL_NAME )" ]; then
		docker volume rm $VOL_NAME > /dev/null
	fi
}

do_build() {
	docker build -t $IMAGE_NAME .
	if [ ! -d "$VOL_MOUNT" ]; then
		mkdir -p $VOL_MOUNT
		docker run --rm $IMAGE_NAME tar cC /home/app-skel . | tar xvC $VOL_MOUNT
	fi
}

do_start() {
	before_start	
	docker run --rm -it --hostname $CONTAINER_NAME --name $CONTAINER_NAME \
		-v $VOL_NAME:/home/app \
		-d \
		$IMAGE_NAME	sleep infinity
	echo "Start Container $CONTAINER_NAME"
}

do_stop() {
	docker rm -f $CONTAINER_NAME
	after_stop
}

usage() {
	echo "USAGE"
	echo " $0 build"
	echo " $0 [ start | stop ]"
	echo " $0 [ root | app ]"
}

case "${1:-}" in
	"start" )  do_start ;;
	"stop"  )  do_stop ;;
	"build" )  do_build ;;
	"root"  )  exec docker exec -it $CONTAINER_NAME bash ;;
	"app"   )  exec docker exec -it $CONTAINER_NAME bash -c 'cd /home/app && exec gosu app bash' ;;
	*       )  usage ;;
esac

