#!/bin/bash

set -e
set -u
set -o errexit
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR="${DIR}/.."
WORK_DIR="${BASE_DIR}/work"

TARGET="${1}"
SUBTARGET="${2}"
RELEASE="${3}"
DOCKER_TAG_PREFIX="${4:-openwrt-imagebuilder}"

DOCKER_TAG="${DOCKER_TAG_PREFIX}-${TARGET}-${SUBTARGET}:${RELEASE}"

if [ "${RELEASE}" == "snapshot" ]; then
    IMAGEBUILDER_BASE_URL="https://downloads.openwrt.org/snapshots/targets/${TARGET}/${SUBTARGET}/"
    IMAGEBUILDER_ARCHIVE="openwrt-imagebuilder-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"
else
    IMAGEBUILDER_BASE_URL="https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${SUBTARGET}/"
    IMAGEBUILDER_ARCHIVE="openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"
fi
IMAGEBUILDER_CHECKSUM="sha256sums"
IMAGEBUILDER_DIRECTORY="${WORK_DIR}/imagebuilder"

IMAGEBUILDER_ARCHIVE_URL="${IMAGEBUILDER_BASE_URL}/${IMAGEBUILDER_ARCHIVE}"
IMAGEBUILDER_CHECKSUM_URL="${IMAGEBUILDER_BASE_URL}/${IMAGEBUILDER_CHECKSUM}"

echo ""
echo "============================================================"
echo "Building '${DOCKER_TAG}'"
echo "============================================================"

if [ -d "${WORK_DIR}" ]; then
    echo "Remove work directory"
    rm -r "${WORK_DIR}"
fi
echo "Create work directory"
mkdir "${WORK_DIR}"

echo "Download checksum"
CHECKSUM_HTTP_CODE=$(curl -s --write-out %{http_code} -o "${WORK_DIR}/${IMAGEBUILDER_CHECKSUM}" "${IMAGEBUILDER_CHECKSUM_URL}")
if [ "$CHECKSUM_HTTP_CODE" == 404 ]; then
    echo "No imagebuilder available for '${DOCKER_TAG}'"
    exit 1
fi
echo "Download archive"
curl -f -s -o "${WORK_DIR}/${IMAGEBUILDER_ARCHIVE}" "${IMAGEBUILDER_ARCHIVE_URL}"

echo "Check archive integrity"
(cd "${WORK_DIR}"; cat "${IMAGEBUILDER_CHECKSUM}" | grep "${IMAGEBUILDER_ARCHIVE}" | sha256sum -c)

echo "Extract archive"
mkdir "${IMAGEBUILDER_DIRECTORY}"
tar -C "${IMAGEBUILDER_DIRECTORY}" -xf "${WORK_DIR}/${IMAGEBUILDER_ARCHIVE}" --strip 1

echo "Build Docker image '${DOCKER_TAG}'"
docker build -t "${DOCKER_TAG}" "${BASE_DIR}" 

echo "${DOCKER_TAG}"
