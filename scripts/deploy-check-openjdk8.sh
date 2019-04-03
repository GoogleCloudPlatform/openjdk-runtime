#!/bin/bash

export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github

cd ${KOKORO_GITHUB_DIR}/${SAMPLE_APP_DIRECTORY}

mvn install --batch-mode -DskipTests -Pruntime.java,deploy.jar

cat <<EOF > ${KOKORO_GITHUB_DIR}/${SAMPLE_APP_DIRECTORY}/app.yaml
runtime: java
env: flex
runtime_config:
  jdk: openjdk8
EOF

source ${KOKORO_GFILE_DIR}/kokoro/deploy_check/deploy_check.sh
