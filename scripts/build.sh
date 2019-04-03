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
  echo "             -p|--publishing-project <publishing_project> - GCP project to use for publishing. Used to generate the destination docker repository name in gcr.io"
  echo "             -m|--module             <module_to_build>    - one of {openjdk8, openjdk11}"
  echo "           [ -t|--tag-suffix ]       <tag_suffix>         - suffix for the tag that is applied to the built image"
  echo "           [ -s|--staging-project ]  <staging_project>    - GCP project to use for staging images. If not provided, the publishing project will be used."
  echo "           [ -l|--local ]                                 - runs the build locally"
  exit 1
}

# Parse arguments to this script
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -p|--publishing-project)
    PUBLISHING_PROJECT="$2"
    shift # past argument
    ;;
    -m|--module)
    MODULE="$2"
    shift # past argument
    ;;
    -t|--tag-suffix)
    TAG_SUFFIX="$2"
    shift # past argument
    ;;
    -s|--staging-project)
    STAGING_PROJECT="$2"
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

if [ -z "${PUBLISHING_PROJECT}" -o -z "${MODULE}" ]; then
  usage
fi

if [ "${MODULE}" == "openjdk8" ]; then
  TAG_PREFIX="8"
elif [ "${MODULE}" == "openjdk11" ]; then
  TAG_PREFIX="11"
else
  echo "${MODULE} is not a supported module"
  usage
fi

if [ -z "$TAG_SUFFIX" ]; then
  TAG_SUFFIX="$(date -u +%Y-%m-%d_%H_%M)"
fi

if [ -z "${STAGING_PROJECT}" ]; then
  STAGING_PROJECT=$PUBLISHING_PROJECT
fi

# export TAG, IMAGE for use in downstream scripts
export TAG="${TAG_PREFIX}-${TAG_SUFFIX}"
export IMAGE="gcr.io/${PUBLISHING_PROJECT}/${RUNTIME_NAME}:${TAG}"
echo "IMAGE: $IMAGE"

STAGING_IMAGE="gcr.io/${STAGING_PROJECT}/${RUNTIME_NAME}_staging:${TAG}"

# build and test the runtime image
BUILD_FLAGS="--config $PROJECT_ROOT/cloudbuild.yaml"
BUILD_FLAGS="$BUILD_FLAGS --substitutions _IMAGE=$IMAGE,_MODULE=$MODULE" # temporarily getting rid of this ,_STAGING_IMAGE=$STAGING_IMAGE"
BUILD_FLAGS="$BUILD_FLAGS $PROJECT_ROOT"

if [ "${LOCAL_BUILD}" = "true" ]; then
  if [ ! $(which cloud-build-local) ]; then
    echo "The cloud-build-local tool is required to perform a local build. To install it, run 'gcloud components install cloud-build-local'"
    exit 1
  fi
  cloud-build-local --dryrun=false $BUILD_FLAGS
else
  gcloud builds submit --timeout=25m $BUILD_FLAGS
fi

