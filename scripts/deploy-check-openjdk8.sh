#!/bin/bash

export KOKORO_GITHUB_DIR=${KOKORO_ROOT}/src/github
source ${KOKORO_GFILE_DIR}/kokoro/common.sh

mkdir -p ${KOKORO_GITHUB_DIR}/${SAMPLE_APP_DIRECTORY}

cd ${KOKORO_GITHUB_DIR}/${SAMPLE_APP_SOURCE_DIRECTORY}

mvn install --batch-mode -DskipTests -Pruntime.java,deploy.war

cat <<EOF > ${KOKORO_GITHUB_DIR}/${SAMPLE_APP_DIRECTORY}/app.yaml
runtime: java
env: flex
runtime_config:
  server: jetty9
resources:
  memory_gb: 2.5
EOF

cd ${KOKORO_GFILE_DIR}/appengine/integration_tests

sudo -E /usr/local/bin/pip install --upgrade -r requirements.txt

if [ -f ${KOKORO_GITHUB_DIR}/${SAMPLE_APP_SOURCE_DIRECTORY}/requirements.txt ]
then
  sudo -E /usr/local/bin/pip install --upgrade -r ${KOKORO_GITHUB_DIR}/${SAMPLE_APP_SOURCE_DIRECTORY}/requirements.txt
fi

export DEPLOY_LATENCY_PROJECT='cloud-deploy-latency'

skip_flag=""

if [ "${SKIP_CUSTOM_LOGGING_TESTS}" = "true" -o "${SKIP_BUILDERS}" = "true" ]; then
  skip_flag="$skip_flag --skip-builders"
fi

if [ "${SKIP_XRT}" = "true" ]; then
  skip_flag="$skip_flag --skip-xrt"
fi

python deploy_check.py -d ${KOKORO_GITHUB_DIR}/${SAMPLE_APP_DIRECTORY} -l ${LANGUAGE} ${skip_flag}
