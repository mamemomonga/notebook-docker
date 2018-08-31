# Debian Linux Dockerfileサンプル

* 時間をJSTにする
* gosu のインストール
* appユーザの作成

## 実行例

イメージのビルド

	$ docker build -t debian-app-user .

コンテナの作成と実行、コンテナは終了と同時に削除

rootユーザで bash実行

	$ docker run --rm -it debian-app-user root

appユーザで bash実行

	$ docker run --rm -it debian-app-user app

イメージの削除

	$ docker rmi debian-app-user

