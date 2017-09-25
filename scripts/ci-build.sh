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

# Build script for CI-like environments. Sets up local dependencies required for performing a
# continuous-integration build.
set -e

dir=$(dirname "$0")

# downloads, unpacks, installs the cloud SDK
source "$dir"/gcloud-init.sh

cd github/openjdk-runtime
TAG_SUFFIX=$(git rev-parse --short HEAD)

echo "Invoking build.sh with GCP_PROJECT=$GCP_PROJECT, MODULE=$MODULE, TAG_SUFFIX=$TAG_SUFFIX"
source ./scripts/build.sh --publishing-project "$GCP_PROJECT" --module "$MODULE" --tag-suffix "$TAG_SUFFIX"

if [ -z "$IMAGE" ]; then
  echo "Error: \$IMAGE not defined. It should be exported by build.sh script."
  exit 1
fi

