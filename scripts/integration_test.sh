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

# Setup environment for CI.
# This script exits as soon as any of the commands in the integration scripts fail
# (including remote failure from Google Cloud Container Builder)
set -e

readonly dir=`dirname $0`

imageUnderTest=$1
if [ -z "${imageUnderTest}" ]; then
  echo "Usage: ${0} <image_under_test>"
  exit 1
fi

${dir}/ae_integration_test.sh ${imageUnderTest}

${dir}/gke_integration_test.sh ${imageUnderTest}
