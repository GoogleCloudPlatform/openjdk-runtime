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

# Build script for CI-like environments, where jobs are configured via environment variables.
set -e

dir=$(dirname $0)

echo "Invoking build.sh with DOCKER_NAMESPACE=$DOCKER_NAMESPACE, TAG=$TAG"
source $dir/build.sh $DOCKER_NAMESPACE $TAG

