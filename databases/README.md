# MariaDB, PostgreSQLを素早く設定する

* MySQL root パスワード, PostgreSQL postgres パスワードを自動生成してデータベースを初期化する
* docker, docker-compose が必要
* MySQLが13306/TCP, PostgreSQLが15432/TCPとしてExposeされる
* それぞれのパスワードは .password-mariadb, .password-pgsql に保存される
* データはNamed Volumeに保存される 
* COMPOSE\_PROJECT\_NAMEは.envで設定する

# 使い方

このコマンドを実行するとすべてのデータベースとパスワードが削除される

	$ ./databases.sh create


