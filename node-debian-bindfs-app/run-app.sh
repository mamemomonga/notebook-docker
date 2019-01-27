#!/bin/bash
set -eu

IMAGE_NAME="debian-app-user-bindfs:latest"
VOL_NAME="debian-app-user-bindfs"
VOL_MOUNT="$(pwd)/app/data"

# ビルド
if [ "${1:-}" == "build" ]; then
	docker build -t $IMAGE_NAME .
fi

mkdir -p $VOL_MOUNT

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
	    -o map=$(id -u)/1000:@$(id -g)/@1000 \
		$VOL_NAME > /dev/null
else
	# おそらくDocker for Macなどである
	# UID,GIDをそれぞれ0(root)にマッピングした
	# ボリュームの作成
	docker volume create \
	    -d lebokus/bindfs \
	    -o sourcePath=$VOL_MOUNT \
	    -o map=$(id -u)/0:@$(id -g)/@0 \
		$VOL_NAME > /dev/null
fi

# コンテナの実行
docker run --rm -it \
	-v $VOL_NAME:/home/node/app/data \
	$IMAGE_NAME	app

# ボリューム削除
if [ -n "$(docker volume ls --format='{{.Name}}' | grep $VOL_NAME )" ]; then
	docker volume rm $VOL_NAME > /dev/null
fi
