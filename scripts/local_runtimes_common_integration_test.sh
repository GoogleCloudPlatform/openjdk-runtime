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

readonly dir=$(dirname $0)
readonly projectRoot="$dir/.."
readonly testAppDir="$projectRoot/java-runtimes-common/test-spring-application"
readonly deployDir="$testAppDir/target/deploy"

APP_IMAGE='openjdk-local-integration'
CONTAINER=${APP_IMAGE}-container
OUTPUT_FILE=${CONTAINER}-output.txt
DEPLOYMENT_TOKEN=$(date -u +%Y-%m-%d-%H-%M-%S-%N)

readonly imageUnderTest=$1
if [[ -z "$imageUnderTest" ]]; then
  echo "Usage: ${0} <image_under_test>"
  exit 1
fi

if [[ ! -f $HOME/.config/gcloud/application_default_credentials.json ]]; then
    # get default application credentials
    gcloud auth application-default login
fi

# build the test app
pushd ${testAppDir}
mvn clean package -Pruntime.custom -Ddeployment.token="${DEPLOYMENT_TOKEN}" -Dapp.deploy.image=${imageUnderTest} -DskipTests --batch-mode
popd

# build app container locally
pushd $deployDir
export STAGING_IMAGE=$imageUnderTest
echo "Building app container..."
docker build -t $APP_IMAGE . || docker build -t $APP_IMAGE .

docker rm -f $CONTAINER || echo "Integration-test-app container is not running, ready to start a new instance."

# run app container locally to test shutdown logging
echo "Starting app container..."
docker run --rm --name $CONTAINER -p 8080 \
        -e "SHUTDOWN_LOGGING_THREAD_DUMP=true" \
        -e "SHUTDOWN_LOGGING_HEAP_INFO=true" \
        -v "$HOME/.config/gcloud/:/root/.config/gcloud" $APP_IMAGE &> $OUTPUT_FILE &

function waitForOutput() {
  found_output='false'
  for run in {1..10}
  do
    grep "$1" $OUTPUT_FILE && found_output='true' && break
    sleep 1
  done

  if [ "$found_output" == "false" ]; then
    cat $OUTPUT_FILE
    echo "did not match '$1' in '$OUTPUT_FILE'"
    exit 1
  fi
}

waitForOutput 'Started Application'

getPort() {
   docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{(index $conf 0).HostPort}}{{end}}' ${CONTAINER}
}


PORT=`getPort`

nslookup `hostname` | grep Address | grep -v 127.0 | awk '{print $2}' > /tmp/myip
MYIP=`cat /tmp/myip`

DEPLOYED_APP_URL=http://$MYIP:$PORT

echo app is deployed to  $DEPLOYED_APP_URL, making sure it accepts connections


until [[ $(curl --silent --fail "$DEPLOYED_APP_URL/deployment.token" | grep "$DEPLOYMENT_TOKEN") ]]; do
  sleep 2
done
popd

docker rm -f metadata || echo "ready to run local cloud builder"

# run in cloud container builder
echo "Running integration tests on application that is deployed at $DEPLOYED_APP_URL"
echo `pwd`
cloud-build-local \
  --config ${dir}/integration_test.yaml \
  --substitutions "_DEPLOYED_APP_URL=$DEPLOYED_APP_URL" \
  --dryrun=false \
  ${dir}
