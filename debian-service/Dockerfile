FROM debian:stretch

# 時間をJSTに設定する
RUN set -xe && \
	rm /etc/localtime && \
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo 'Asia/Tokyo' > /etc/timezone

# インストール
RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		postfix \
		rsyslog && \
	rm -rf /var/lib/apt/lists/*

# rsyslogd のすべてのログを/dev/stderr に出力する
RUN set -xe && \
	ln -sf /dev/stderr /var/log/auth.log    && \
	ln -sf /dev/stderr /var/log/syslog      && \
	ln -sf /dev/stderr /var/log/cron.log    && \
	ln -sf /dev/stderr /var/log/daemon.log  && \
	ln -sf /dev/stderr /var/log/kern.log    && \
	ln -sf /dev/stderr /var/log/lpr.log     && \
	ln -sf /dev/stderr /var/log/mail.log    && \
	ln -sf /dev/stderr /var/log/user.log    && \
	ln -sf /dev/stderr /var/log/mail.info   && \
	ln -sf /dev/stderr /var/log/mail.warn   && \
	ln -sf /dev/stderr /var/log/mail.err    && \
	ln -sf /dev/stderr /var/log/debug       && \
	ln -sf /dev/stderr /var/log/messages   

# entrypoint.sh の追加
COPY entrypoint.sh /

# entrypointの設定
ENTRYPOINT ["/entrypoint.sh"]

