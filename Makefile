tag := dimitrovadrian/webruntime

time := $(shell date +"%Y-%m-%dT%H:%M:%S%z")
build := $(shell git rev-parse --short HEAD)

build:
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-12.04" 		--file "Dockerfile.ubuntu-12.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-12.04-dev" 	--file "Dockerfile.ubuntu-12.04" --target "dev" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-14.04" 		--file "Dockerfile.ubuntu-14.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-14.04-dev" 	--file "Dockerfile.ubuntu-14.04" --target "dev" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-18.04" 		--file "Dockerfile.ubuntu-18.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-18.04-dev" 	--file "Dockerfile.ubuntu-18.04" --target "dev" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-20.04" 		--file "Dockerfile.ubuntu-20.04" --target "base" 	--label "time=$(time)" 	.
	DOCKER_BUILDKIT=1 docker build --tag "$(tag):ubuntu-20.04-dev" 	--file "Dockerfile.ubuntu-20.04" --target "dev" 	--label "time=$(time)" 	.

publish:
	docker push "$(tag):ubuntu-12.04"
	docker push "$(tag):ubuntu-12.04-dev"
	docker push "$(tag):ubuntu-14.04"
	docker push "$(tag):ubuntu-14.04-dev"
	docker push "$(tag):ubuntu-18.04"
	docker push "$(tag):ubuntu-18.04-dev"
	docker push "$(tag):ubuntu-20.04"
	docker push "$(tag):ubuntu-20.04-dev"

latest:
	docker tag "$(tag):ubuntu-20.04" "$(tag):latest"
	docker push "$(tag):latest"

all: build publish latest
