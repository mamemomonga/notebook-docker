# Alpine Linux Dockerfileサンプル

* 時間をJSTにする
* su-exec のインストール
* appユーザの作成

## 実行例

イメージのビルド

	$ docker build -t alpine-app-user .

コンテナの作成と実行、コンテナは終了と同時に削除

rootユーザ で busybox ash 実行

	$ docker run --rm -it alpine-app-user root

appユーザ で busybox ash 実行

	$ docker run --rm -it alpine-app-user app

イメージの削除

	$ docker rmi alpine-app-user

