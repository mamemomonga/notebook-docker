FROM debian:buster

RUN set -xe && \
	rm -f /etc/localtime && \
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo 'Asia/Tokyo' > /etc/timezone

RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		gosu curl apt-transport-https ca-certificates \
		git-core locales vim sudo screen make man && \
	rm -rf /var/lib/apt/lists/*

RUN set -xe && \
	perl -i -nlpE 's!^# (en_US.UTF-8 UTF-8)!$1!; s!^# (ja_JP.UTF-8 UTF-8)!$1!; ' /etc/locale.gen && \
	locale-gen && \
	update-locale LANG=en_US.UTF-8 && \
	sh -c "echo '3' | update-alternatives --config editor"

RUN set -xe && \
	useradd -m -s /bin/bash -u 10000 app && \
	mv /home/app /home/app-skel

ADD assets/ /

RUN set -xe && \
	echo 'source /etc/screenrc.local' >> /etc/screenrc

