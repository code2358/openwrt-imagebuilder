#!/bin/bash

set -e
set -u
set -o errexit
set -o pipefail

DOCKER_REGISTRY="${1}"
DOCKER_REGISTRY_GROUP="${2}"
DOCKER_TAG="${3}"

DOCKER_REGISTRY_TAG="${DOCKER_REGISTRY}/${DOCKER_REGISTRY_GROUP}/${DOCKER_TAG}"
DOCKER_CLI="docker"

echo "Tag '${DOCKER_TAG}' as '${DOCKER_REGISTRY_TAG}'"
docker tag "${DOCKER_TAG}" "${DOCKER_REGISTRY_TAG}"

echo "Login to '${DOCKER_REGISTRY}'"
echo "$DOCKER_PASSWORD" | docker login ${DOCKER_REGISTRY} -u "$DOCKER_USERNAME" --password-stdin

echo "Push to '${DOCKER_REGISTRY}'"
docker push "${DOCKER_REGISTRY_TAG}"
