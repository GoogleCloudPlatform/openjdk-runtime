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

#
# Fetch and execute the structure test framework run script.
#
dir=`dirname $0`
scriptPath=https://raw.githubusercontent.com/GoogleCloudPlatform/runtimes-common/a5efef7f1f2cfd60814641fcff8239ea301e661d/structure_tests/ext_run.sh
destDir=$dir/../target
fileName=$destDir/run_structure_tests.sh

if [ ! -d $destDir ]
then
  mkdir -p $destDir
fi

curl $scriptPath > $fileName
bash $fileName "$@"
