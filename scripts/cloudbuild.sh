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

dir=`dirname $0`
projectRoot=$dir/..
buildProperties=$projectRoot/target/build.properties

RUNTIME_NAME="openjdk"
DOCKER_NAMESPACE=$1
if [ -z "${DOCKER_NAMESPACE}" ]; then
  echo "Usage: ${0} <docker_namespace> [--local]"
  exit 1
fi
if [ "$2" == "--local" ]; then
  LOCAL_BUILD=true
fi

# reads a property value from a .properties file
function read_prop {
  grep "${1}" $buildProperties | cut -d'=' -f2
}

# invoke local maven to output build properties file
mvn clean --non-recursive properties:write-project-properties@build-properties

export DOCKER_TAG_LONG=$(read_prop "docker.tag.long")
export IMAGE="${DOCKER_NAMESPACE}/${RUNTIME_NAME}:${DOCKER_TAG_LONG}"
echo "IMAGE: $IMAGE"

mkdir -p $projectRoot/target
envsubst < $projectRoot/cloudbuild.yaml.in > $projectRoot/target/cloudbuild.yaml

# build and test the runtime image
if [ "$LOCAL_BUILD" = "true" ]; then
  source $dir/cloudbuild_local.sh --config=$projectRoot/target/cloudbuild.yaml
else
  gcloud container builds submit --config=$projectRoot/target/cloudbuild.yaml .
fi

