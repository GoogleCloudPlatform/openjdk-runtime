#!/bin/bash

# Copyright 2016 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

projectRoot=`dirname $0`/..
buildProperties=$projectRoot/target/build.properties

# reads a property value from a .properties file
function read_prop {
  grep "${1}" $buildProperties | cut -d'=' -f2
}

# invoke local maven to output build properties file
mvn properties:write-project-properties@build-properties

DOCKER_NAMESPACE='gcr.io/$PROJECT_ID'
RUNTIME_NAME="openjdk"
export DOCKER_TAG_LONG=$(read_prop "docker.tag.long")
export IMAGE="${DOCKER_NAMESPACE}/${RUNTIME_NAME}:${DOCKER_TAG_LONG}"
echo "IMAGE: $IMAGE"

mkdir -p $projectRoot/target
envsubst < $projectRoot/cloudbuild.yaml.in > $projectRoot/target/cloudbuild.yaml

if [ "$1" == "--local" ]
then
  export PROJECT_ID=${PROJECT_ID:-"local-test-project"}
  envsubst < $projectRoot/target/cloudbuild.yaml > $projectRoot/target/cloudbuild_local.yaml
  curl -s https://raw.githubusercontent.com/GoogleCloudPlatform/python-runtime/master/scripts/local_cloudbuild.py | \
  python3 - --config=$projectRoot/target/cloudbuild_local.yaml --output_script=$projectRoot/target/cloudbuild_local.sh
else
  gcloud container builds submit --config=$projectRoot/target/cloudbuild.yaml .
fi
