#!/bin/bash
set -eu

NAME="ubuntu-bindfs-simple-workspace"

IMAGE_NAME="$NAME:latest"
CONTAINER_NAME=$NAME"_1"
VOL_NAME=$NAME"_1"
VOL_MOUNT="$(pwd)/home/app"

# ビルド
if [ "${1:-}" == "build" ]; then
	shift
	docker build -t $IMAGE_NAME .
fi

if [ ! -d "$VOL_MOUNT" ]; then
	mkdir -p $VOL_MOUNT
	docker run --rm $IMAGE_NAME expand-app-skel | tar xvC $VOL_MOUNT
fi

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

# コンテナの実行
docker run --rm -it --hostname $CONTAINER_NAME --name $CONTAINER_NAME \
	-v $VOL_NAME:/home/app \
	$IMAGE_NAME	$@

# ボリューム削除
if [ -n "$(docker volume ls --format='{{.Name}}' | grep $VOL_NAME )" ]; then
	docker volume rm $VOL_NAME > /dev/null
fi

