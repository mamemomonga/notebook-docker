FROM node:11-stretch

RUN set -xe && \
	rm -f /etc/localtime && \
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo 'Asia/Tokyo' > /etc/timezone

RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		gosu curl apt-transport-https && \
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg > /tmp/pubkey.gpg && \
	apt-key add /tmp/pubkey.gpg && \
	rm /tmp/pubkey.gpg && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
	apt-get update && \
	apt-get install -y yarn	&& \
	rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /
COPY app/package.json /home/node/app/package.json
RUN set -xe && \
	chown -R node:node /home/node/app && \
	cd /home/node/app && \
	gosu node yarn -D

ADD app /home/node/app

ENTRYPOINT ["/entrypoint.sh"]

