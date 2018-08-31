# service起動サンプル

service コマンドでpostfixとrsyslogを同時に起動するサンプル

* 時間をJSTにする
* postfix, rsyslog のインストール

## 実行例

イメージのビルド

	$ docker build -t debian-service .

サービス起動、コンテナは終了と同時に削除

	$ docker run --rm -it debian-service run

バックグラウンドで起動

	$ docker run -d --name=debian-service-1 debian-service run

ログを確認

	$ docker logs debian-service-1

バックグラウンドで起動しているコンテナにbashで入る

	$ docker exec -it debian-service-1 bash

コンテナの停止

	$ docker stop debian-service-1

コンテナの削除

	$ docker rm debian-service-1

rootユーザで bash実行、コンテナは終了と同時に削除

	$ docker run --rm -it debian-service root

イメージの削除

	$ docker rmi debian-service

