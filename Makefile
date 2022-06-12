tag := dimitrovadrian/webruntime

time := $(shell date +"%Y-%m-%dT%H:%M:%S%z")
build := $(shell git rev-parse --short HEAD)

build-2204:
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-22.04" 		--file "Dockerfile.ubuntu-22.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-22.04-dev" 	--file "Dockerfile.ubuntu-22.04" --target "dev" 	--label "time=$(time)" 	.
build-2004:
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-20.04" 		--file "Dockerfile.ubuntu-20.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-20.04-dev" 	--file "Dockerfile.ubuntu-20.04" --target "dev" 	--label "time=$(time)" 	.
build-1804:
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-18.04" 		--file "Dockerfile.ubuntu-18.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-18.04-dev" 	--file "Dockerfile.ubuntu-18.04" --target "dev" 	--label "time=$(time)" 	.
build-1404:
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-14.04" 		--file "Dockerfile.ubuntu-14.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-14.04-dev" 	--file "Dockerfile.ubuntu-14.04" --target "dev" 	--label "time=$(time)" 	.
build-1204:
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-12.04" 		--file "Dockerfile.ubuntu-12.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-12.04-dev" 	--file "Dockerfile.ubuntu-12.04" --target "dev" 	--label "time=$(time)" 	.

push-2204:
	docker push "$(tag):ubuntu-22.04"
	docker push "$(tag):ubuntu-22.04-dev"
push-2004:
	docker push "$(tag):ubuntu-20.04"
	docker push "$(tag):ubuntu-20.04-dev"
push-1804:
	docker push "$(tag):ubuntu-18.04"
	docker push "$(tag):ubuntu-18.04-dev"
push-1404:
	docker push "$(tag):ubuntu-14.04"
	docker push "$(tag):ubuntu-14.04-dev"
push-1204:
	docker push "$(tag):ubuntu-12.04"
	docker push "$(tag):ubuntu-12.04-dev"

latest:
	docker tag "$(tag):ubuntu-20.04" "$(tag):latest"
	docker push "$(tag):latest"

build: build-2204 build-2004 build-1804 build-1204
push: push-2204 push-2004 push-1804 push-1204
publish: push latest
all: build
