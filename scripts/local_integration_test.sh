#!/bin/bash

# Copyright 2017 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# exit on command failure
set -e

function usage() {
  echo $1
  echo "Usage: ${0} <image_under_test> [OPTIONS]"
  echo "Options:"
  echo "-v: verbose (displays logs for container and test driver)"
  echo "-g: test integration with GCP services (requires GOOGLE_APPLICATION_CREDENTIALS)"
  exit 1
}

function getPort() {
   docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}}{{end}}' ${CONTAINER}
}


function waitForOutput() {
  found_output='false'
  for run in {1..10}
  do
    grep "$1" ${OUTPUT_FILE} && found_output='true' && break
    sleep 1
  done

  if [ "$found_output" == "false" ]; then
    cat ${OUTPUT_FILE}
    echo "did not match '$1' in '$OUTPUT_FILE'"
    exit 1
  fi
}


readonly dir=$(dirname $0)
readonly projectRoot="$dir/.."
readonly testAppDir="$projectRoot/test-application"
readonly deployDir="$testAppDir/target/deploy"

APP_IMAGE='openjdk-local-integration'
TEST_DRIVER_IMAGE='gcr.io/java-runtime-test/integration-test'
CONTAINER=${APP_IMAGE}-container
OUTPUT_FILE=${CONTAINER}-output.txt
DEPLOYMENT_TOKEN=$(uuidgen)

readonly imageUnderTest=$1
if [[ -z "$imageUnderTest" ]]; then
    usage "Error: missing image!"
fi

shift

while getopts ":gv" opt; do
  case $opt in
    v)
      VERBOSE="true"
      DRIVER_OPTS="--verbose"
      ;;
    g)
      WITH_GCP="true"
      ;;
    \?)
      usage "Invalid option: -$OPTARG"
      ;;
  esac
done

# build the test app
pushd ${testAppDir}
mvn clean package -Ddeployment.token="${DEPLOYMENT_TOKEN}" -DskipTests --batch-mode
popd

# build app container locally
pushd $deployDir
export STAGING_IMAGE=$imageUnderTest
envsubst < Dockerfile.in > Dockerfile
echo "Building app container..."
docker build -t $APP_IMAGE . || gcloud docker -- build -t $APP_IMAGE . || usage "Error building test-app image from base image \"${imageUnderTest}\", please make sure it exists!"


if [[ "$WITH_GCP" ]]; then
    echo "--------"
    echo "Starting test in GCP mode!"
    echo "--------"

    if [[ -z ${GOOGLE_APPLICATION_CREDENTIALS} ]]; then
        usage "Error: In GCP mode GOOGLE_APPLICATION_CREDENTIALS must be set."
    fi
    # we setup the container for GCP relying on the environment
    GCP_CONTAINER_OPTS="-v ${GOOGLE_APPLICATION_CREDENTIALS}:/gcp_creds.json -e GOOGLE_APPLICATION_CREDENTIALS=/gcp_creds.json"
    APP_CMD=
    DRIVER_OPTS="$DRIVER_OPTS --skip-standard-logging-tests \
                                --skip-custom-tests"
else
    echo "--------"
    echo "Starting test in MOCK-GCP mode!"
    echo "--------"
    # mock-gcp profile, the container is started as mock-gcp
    GCP_CONTAINER_OPTS=
    APP_CMD='java -Dspring.profiles.active=mock-gcp -jar app.jar'
    DRIVER_OPTS="$DRIVER_OPTS --skip-monitoring-tests   \
                        --skip-custom-logging-tests     \
                        --skip-standard-logging-tests   \
                        --skip-custom-tests"
fi

docker rm -f $CONTAINER &>/dev/null || echo "Integration-test-app container is not running, ready to start a new instance."


# run app container locally to test shutdown logging
echo "Starting app container..."
docker run --rm --name ${CONTAINER} ${GCP_CONTAINER_OPTS} -p 8080 \
            -e "SHUTDOWN_LOGGING_THREAD_DUMP=true" \
            -e "SHUTDOWN_LOGGING_HEAP_INFO=true" \
            ${APP_IMAGE} ${APP_CMD} &> ${OUTPUT_FILE} &

waitForOutput 'Started Application'

PORT=`getPort`

DEPLOYED_APP_URL=http://localhost:${PORT}

echo "App deployed to URL: $DEPLOYED_APP_URL, making sure it accepts connections..."

until [[ $(curl --silent --fail "${DEPLOYED_APP_URL}/deployment.token" | grep "${DEPLOYMENT_TOKEN}") ]]; do
  sleep 2
done

DRIVER_OPTS="${DRIVER_OPTS} --url=${DEPLOYED_APP_URL}"

[[ "${VERBOSE}" ]] && docker logs -f ${CONTAINER} &

docker run --rm ${GCP_CONTAINER_OPTS} --net=host ${TEST_DRIVER_IMAGE} ${DRIVER_OPTS}

docker stop ${CONTAINER}

docker rmi -f ${APP_IMAGE}

echo 'verify thread dump'
waitForOutput 'Full thread dump OpenJDK 64-Bit Server VM'

echo 'verify heap info'
waitForOutput 'num.*instances.*bytes.*class name'

popd

echo 'OK'