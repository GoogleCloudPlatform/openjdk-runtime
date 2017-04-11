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

dir=$(dirname $0)
projectRoot=$dir/..

RUNTIME_NAME="openjdk"
DOCKER_TAG_PREFIX="8"
DOCKER_NAMESPACE=$1
DOCKER_TAG=$2

if [ -z "${DOCKER_NAMESPACE}" ]; then
  echo "Usage: ${0} <docker_namespace> [docker_tag] [--local]"
  exit 1
fi

if [ -z "${DOCKER_TAG}" ]; then
  DOCKER_TAG="${DOCKER_TAG_PREFIX}-$(date -u +%Y-%m-%d_%H_%M)"
fi

if [ "$3" == "--local" ]; then
  LOCAL_BUILD=true
fi

IMAGE="${DOCKER_NAMESPACE}/${RUNTIME_NAME}:${DOCKER_TAG}"
echo "IMAGE: $IMAGE"

# build and test the runtime image
if [ "$LOCAL_BUILD" = "true" ]; then
  source $dir/cloudbuild_local.sh \
    --config=$projectRoot/cloudbuild.yaml \
    --substitutions="_IMAGE=$IMAGE,_DOCKER_TAG=$DOCKER_TAG"
else
  gcloud container builds submit \
    --config=$projectRoot/cloudbuild.yaml \
    --substitutions="_IMAGE=$IMAGE,_DOCKER_TAG=$DOCKER_TAG" \
    $projectRoot
fi

