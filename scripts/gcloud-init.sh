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


# Set up gcloud and auth
set -ex

DIR=$(pwd)

if [ -z $GCLOUD_FILE ]; then
  echo '$GCLOUD_FILE environment variable must be set.'
  exit 1
fi

if [ -z $KEYFILE ]; then
  echo '$KEYFILE environment variable must be set.'
  exit 1
fi

if [ -z $GCP_PROJECT ]; then
  echo '$GCP_PROJECT environment variable must be set.'
  exit 1
fi

LOCAL_GCLOUD_FILE=gcloud.tar.gz
cp $GCLOUD_FILE $LOCAL_GCLOUD_FILE

# Hide the output here, it's long.
tar -xzf $LOCAL_GCLOUD_FILE
export PATH=$DIR/google-cloud-sdk/bin:$PATH

gcloud auth activate-service-account --key-file=$KEYFILE
gcloud config set project $GCP_PROJECT
gcloud components install beta -q
