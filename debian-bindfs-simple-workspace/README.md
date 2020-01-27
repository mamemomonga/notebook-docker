# 作業環境

Debian Busterの作業環境です。

コンテナ内部の  の appユーザが作成され、
ローカル の home/app が bindfs により /home/app にマウントされます。

コンテナ内部の /home/app の appユーザ(UID:10000, GID:10000) のファイルは、
ローカルがLinuxの場合はローカルのGID,UIDに、
ローカルがmacOSの場合は0(root)にマッピングされ、docker for Macの機能でローカルUID,GIDにマッピングされます。

# 使い方 

## 設定の確認

	$ ./workspace.sh
	$ vim config

## ビルド
docker build とホームディレクトリの生成を行う

	$ ./workspace.sh build

## コンテナの起動

	$ ./workspace.sh start

## rootでコンテナの中に入る

	$ ./workspace.sh root

## appでコンテナの中に入る

	$ ./workspace.sh app

## コンテナの停止

	$ ./workspace.sh stop

