#!/bin/bash
export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github
source ${KOKORO_GFILE_DIR}/kokoro/common.sh

cd ${KOKORO_GITHUB_DIR}/openjdk-runtime

params="--publishing-project ${PUBLISHING_PROJECT} --staging-project ${GCP_TEST_PROJECT} --module ${MODULE}"
if [ -n "${TAG_SUFFIX}" ]; then
  params="$params --tag-suffix ${TAG_SUFFIX}"
fi

source ./scripts/build.sh ${params}

METADATA=$(pwd)/METADATA
cd ${KOKORO_GFILE_DIR}/kokoro
python note.py openjdk -m ${METADATA} -t ${TAG}
