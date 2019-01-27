.PHONY: build
IMAGE=debian-app-user-bindfs
CONTAINER=debian-app-user-bindfs1

build:
	docker build -t $(IMAGE) .

hello:
	docker run --rm -it --name $(CONTAINER) $(IMAGE) hello

