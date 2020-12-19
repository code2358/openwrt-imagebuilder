#!/bin/bash

set -e
set -u
set -o errexit
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR="${DIR}/.."
CONFIGURATION_DIR="${BASE_DIR}/configuration"

RELEASE="${1}"
DOCKER_REGISTRY="${2:-}"
DOCKER_REGISTRY_GROUP="${3:-}"

if [ "${RELEASE}" == "master" ]; then
    RELEASE="snapshot"
fi

TARGETS=$(cat "${CONFIGURATION_DIR}"/targets.txt)

for TARGET_FULL in ${TARGETS}; do
    IFS='/'; TARGET_PARAMERTERS=($TARGET_FULL); unset IFS;
    TARGET="${TARGET_PARAMERTERS[0]}"
    SUBTARGET="${TARGET_PARAMERTERS[1]}"
    
    DOCKER_TAG=$("${DIR}"/build.sh "${TARGET}" "${SUBTARGET}" "${RELEASE}" | tee /dev/tty | tail -n1)
    
    if [ ! -z  "${DOCKER_REGISTRY}" ]; then
        "${DIR}"/push-to-registry.sh "${DOCKER_REGISTRY}" "${DOCKER_REGISTRY_GROUP}" "${DOCKER_TAG}"
    fi
done
