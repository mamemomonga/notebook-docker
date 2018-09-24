FROM debian:stretch

# 時間をJSTに設定する
RUN set -xe && \
	rm -f /etc/localtime && \
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo 'Asia/Tokyo' > /etc/timezone

# インストール
RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		gosu && \
	rm -rf /var/lib/apt/lists/*

# appユーザを作成
RUN set -xe && \
	useradd -m -u 10000 app

# entrypoint.sh の追加
COPY entrypoint.sh /

# entrypointの設定
ENTRYPOINT ["/entrypoint.sh"]

