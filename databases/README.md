# MariaDB, PostgreSQL 初期化ツールとテンプレート

* docker, docker-compose が必要
* MySQLが13306/TCP, PostgreSQLが15432/TCPとしてExposeされる
* データはNamed Volumeに保存される 
* MySQL root パスワード, PostgreSQL postgres パスワードを自動生成してデータベースを初期化する
* データベースとユーザを複数作成し、ランダムなパスワードを設定する
* 設定やパスワードは .env に保存される。ファイルがない場合は自動生成される。

# 使い方

	$ ./databases.sh create
	$ docker-compose up -d
	$ ./database.sh myql
	MariaDB [(none)]> exit

	$ ./database.sh psql
	postgres=# \q

	$ ./database.sh destroy

