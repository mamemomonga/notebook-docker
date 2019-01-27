# node.js Dockerサンプル

* babel-node でHello World!
* data 以下に「Hello World!」と書かれたファイルを作成
* プログラムはコンテナ内の node ユーザで実行
* 書き出したファイルとグループを bindfs プラグインでローカルのユーザと同じにする
* 最初に package.json を追加して yarn install することにより docker build が早い。
* ローカルの node_modules は .dockerignore で除外

# 実行方法

	$ ./run-app.sh build

