#!/bin/sh
DOCKER_USER="dimitrovadrian"
CONTAINER_IMAGE_NAME="webruntime"
# SUFFIX="-edge"
# LATEST=
# NODEV=
# PULL_BASE=
# PUBLISH=

if [ -f ".env" ]; then
    source .env
fi

if [ -z "$1" ]; then
    TAGS="$(ls Dockerfile.* | sed -r 's/Dockerfile\.//' | sort)"
else
    TAGS=$(echo $@ | sed -r 's/Dockerfile\.//')
fi

# BuiltKit is required to build images
export DOCKER_BUILDKIT=1

echo "Build Plan:"
echo " * Latest: ${LATEST:-No}"
if [ -z "$NODEV" ]; then
    echo " * Dev: Yes"
else
    echo " * Dev: No"
fi
echo " * Images:" $TAGS
echo " * Suffix: $SUFFIX"
echo
echo

errors=""

docker_build_args="
    --compress
    --label "$DOCKER_USER.$CONTAINER_IMAGE_NAME.time=$(date +"%Y-%m-%dT%H:%M:%S%z")"
    --label "$DOCKER_USER.$CONTAINER_IMAGE_NAME.build=$(git rev-parse --short HEAD)"
"

if [ -n "$PULL_BASE" ]; then
    docker_build_args="$docker_build_args --pull"
fi

for tag in $TAGS; do
    dockerfile="Dockerfile.$tag"

    echo "IMAGE: $DOCKER_USER/$CONTAINER_IMAGE_NAME:$tag$SUFFIX"
    docker build "$PWD" $docker_build_args \
        --label "$DOCKER_USER.$CONTAINER_IMAGE_NAME.flavour=$tag" \
        --file "$dockerfile" \
        --target "base" \
        --tag "$DOCKER_USER/$CONTAINER_IMAGE_NAME:$tag$SUFFIX"

    if [ $? -ne 0 ]; then
        echo "Build failed for $tag$SUFFIX";
        errors="$errors $dockerfile"
        continue
    fi

    if [ -n "$PUBLISH" ]; then
        docker push "$DOCKER_USER/$CONTAINER_IMAGE_NAME:$tag$SUFFIX"
    fi
    echo

    if [ -z "$NODEV" ]; then
        echo "IMAGE: $DOCKER_USER/$CONTAINER_IMAGE_NAME:$tag-dev$SUFFIX"
        docker build "$PWD" $docker_build_args \
            --label "$DOCKER_USER.$CONTAINER_IMAGE_NAME.flavour=$tag" \
            --label "$DOCKER_USER.$CONTAINER_IMAGE_NAME.dev=true" \
            --file "$dockerfile" \
            --target "dev" \
            --compress \
            --tag "$DOCKER_USER/$CONTAINER_IMAGE_NAME:$tag-dev$SUFFIX"

        if [ $? -ne 0 ]; then
            echo "Build failed for $tag-dev$SUFFIX";
            errors="$errors $dockerfile"
            continue
        fi

        if [ -n "$PUBLISH" ]; then
            docker push "$DOCKER_USER/$CONTAINER_IMAGE_NAME:$tag-dev$SUFFIX"
        fi
        echo
    fi

done

if [ -n "$LATEST" ]; then
    echo "Tagging latest from $DOCKER_USER/$CONTAINER_IMAGE_NAME:$LATEST$SUFFIX"
    docker tag "$DOCKER_USER/$CONTAINER_IMAGE_NAME:$LATEST$SUFFIX" "$DOCKER_USER/$CONTAINER_IMAGE_NAME:latest$SUFFIX"
    if [ -n "$PUBLISH" ]; then
        docker push "$DOCKER_USER/$CONTAINER_IMAGE_NAME:latest$SUFFIX"
    fi
fi

if [ -n "$errors" ]; then
    echo "ERRORS: $errors"
fi
