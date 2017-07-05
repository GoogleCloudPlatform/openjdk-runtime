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

# - Builds the test app;
# - Creates a GCE VM as per
#   https://cloud.google.com/container-optimized-os/docs/how-to/create-configure-instance;
# - Boots integration test suite from GKE.

# Immediately exits in the presence of an error.
set -e

readonly dir=$(dirname $0)
readonly projectRoot="$dir/.."
readonly testAppDir="$projectRoot/test-application"
readonly deployDir="$testAppDir/target/deploy"
readonly imageName="openjdk-gce-integration-test"

readonly imageUnderTest=$1
if [[ -z "$imageUnderTest" ]]; then
  echo "Usage: ${0} <image_under_test>"
  exit 1
fi

readonly projectName=$(gcloud info \
                | awk '/^Project: / { print $2 }' \
                | sed 's/\[//'  \
                | sed 's/\]//')

readonly imageUrl="gcr.io/$projectName/$imageName"

# Build the test app.
pushd ${testAppDir}
mvn clean package
popd

pushd ${deployDir}
export STAGING_IMAGE=${imageUnderTest}
envsubst < "Dockerfile.in" > "Dockerfile"
export APPLICATION_IMAGE=${imageUrl}

echo "Deploying image to Google Container Registry..."
gcloud docker -- build -t "$imageName" .
gcloud docker -- tag "$imageName" "$imageUrl"
gcloud docker -- push $imageUrl

export CONTAINER_USER_NAME="applicationuser"
envsubst < "gce_integration_test_metadata.in" > "gce_integration_test_metadata"
popd

# Creates a new GCE VM with cloud-init script to boot up container.
echo "Creating a GCE VM and booting up container from ${imageUrl}..."
# cos-beta-60-9592-31-0 is used because external networks aren't available at image start time for
# older images. b/63014697
gcloud compute instances create ${imageName} \
  --image cos-beta-60-9592-31-0 \
  --image-project cos-cloud \
  --metadata-from-file user-data=${deployDir}/gce_integration_test_metadata \
  --tags=http-server \
  --zone us-east1-b

DEPLOYED_APP_URL=$(gcloud compute instances list ${imageName} \
 | sed -n 2p | awk '{print $5}')

echo "Running integration tests on application that is deployed at $DEPLOYED_APP_URL"
gcloud container builds submit \
  --config ${dir}/integration_test.yaml \
  --substitutions "_DEPLOYED_APP_URL=http://$DEPLOYED_APP_URL" \
  ${dir}

gcloud compute instances delete ${imageName} --zone us-east1-b
