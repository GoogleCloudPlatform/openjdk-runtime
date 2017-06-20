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
readonly testAppDir="$projectRoot/test-application"
readonly deployDir="$testAppDir/target/deploy"

APP_IMAGE='openjdk-local-integration'
CONTAINER=${APP_IMAGE}-container
OUTPUT_FILE=${CONTAINER}-output.txt

readonly imageUnderTest=$1
if [[ -z "$imageUnderTest" ]]; then
  echo "Usage: ${0} <image_under_test>"
  exit 1
fi

# build the test app
pushd ${testAppDir}
mvn clean install -DskipTests --batch-mode
popd

# build app container locally
pushd $deployDir
export STAGING_IMAGE=$imageUnderTest
envsubst < Dockerfile.in > Dockerfile
echo "Building app container..."
docker build -t $APP_IMAGE . || gcloud docker -- build -t $APP_IMAGE .

# run app container locally to test shutdown logging
echo "Starting app container..."
docker run --rm --name $CONTAINER -e "SHUTDOWN_LOGGING_THREAD_DUMP=true" -e "SHUTDOWN_LOGGING_HEAP_INFO=true" $APP_IMAGE &> $OUTPUT_FILE &

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

docker stop $CONTAINER

docker rmi $APP_IMAGE

echo 'verify thread dump'
waitForOutput 'Full thread dump OpenJDK 64-Bit Server VM'

echo 'verify heap info'
waitForOutput 'num.*instances.*bytes.*class name'

popd

echo 'OK'