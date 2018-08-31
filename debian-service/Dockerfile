FROM debian:stretch

# 時間をJSTに設定する
RUN set -xe && \
	rm /etc/localtime && \
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo 'Asia/Tokyo' > /etc/timezone

# rsyslogd のすべてのログを/dev/stderr に出力する
# docker logs で参照できる
RUN set -xe && \
	ln -s /dev/stderr /var/log/auth.log    && \
	ln -s /dev/stderr /var/log/syslog      && \
	ln -s /dev/stderr /var/log/cron.log    && \
	ln -s /dev/stderr /var/log/daemon.log  && \
	ln -s /dev/stderr /var/log/kern.log    && \
	ln -s /dev/stderr /var/log/lpr.log     && \
	ln -s /dev/stderr /var/log/mail.log    && \
	ln -s /dev/stderr /var/log/user.log    && \
	ln -s /dev/stderr /var/log/mail.info   && \
	ln -s /dev/stderr /var/log/mail.warn   && \
	ln -s /dev/stderr /var/log/mail.err    && \
	ln -s /dev/stderr /var/log/debug       && \
	ln -s /dev/stderr /var/log/messages   

# インストール
RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		postfix \
		rsyslog && \
	rm -rf /var/lib/apt/lists/*

# entrypoint.sh の追加
COPY entrypoint.sh /

# entrypointの設定
ENTRYPOINT ["/entrypoint.sh"]

