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

usage() {
  echo "Usage: ${0} <args>"
  echo "  where <args> include:"
  echo "             -d|--docker-namespace <docker_namespace> - a docker repository beginning with gcr.io"
  echo "             -m|--module           <module_to_build>  - one of {openjdk8, openjdk9}"
  echo "           [ -l|--local ]                             - runs the build locally"
  exit 1
}

# Parse arguments to this script
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--docker-namespace)
    DOCKER_NAMESPACE="$2"
    shift # past argument
    ;;
    -m|--module)
    MODULE="$2"
    shift # past argument
    ;;
    -l|--local)
    LOCAL_BUILD="true"
    ;;
    *)
    # unknown option
    usage
    ;;
  esac
  shift
done

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT=$DIR/..
RUNTIME_NAME="openjdk"
BUILD_TIMESTAMP="$(date -u +%Y-%m-%d_%H_%M)"

if [ -z "${DOCKER_NAMESPACE}" -o -z "${MODULE}" ]; then
  usage
fi

if [ "${MODULE}" == "openjdk8" ]; then
  TAG_PREFIX="8"
elif [ "${MODULE}" == "openjdk9" ]; then
  TAG_PREFIX="9"
else
  echo "${MODULE} is not a supported module"
  usage
fi

# export TAG for use in downstream scripts
export TAG="${TAG_PREFIX}-${BUILD_TIMESTAMP}"

IMAGE="${DOCKER_NAMESPACE}/${RUNTIME_NAME}:${TAG}"
echo "IMAGE: $IMAGE"

# build and test the runtime image
if [ "${LOCAL_BUILD}" = "true" ]; then
  source $DIR/cloudbuild_local.sh \
    --config=$PROJECT_ROOT/cloudbuild.yaml \
    --substitutions="_IMAGE=$IMAGE,_MODULE=$MODULE"
else
  gcloud container builds submit \
    --config=$PROJECT_ROOT/cloudbuild.yaml \
    --substitutions="_IMAGE=$IMAGE,_MODULE=$MODULE" \
    $PROJECT_ROOT
fi

