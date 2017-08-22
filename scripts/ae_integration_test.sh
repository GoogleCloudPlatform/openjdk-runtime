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

# Runs integration tests on a given runtime image

readonly dir=`dirname $0`
readonly projectRoot=$dir/..
readonly testAppDir=$projectRoot/test-application
readonly deployDir=$testAppDir/target/deploy
readonly DEPLOYMENT_TOKEN=$(uuidgen)

readonly imageUnderTest=$1
if [ -z "${imageUnderTest}" ]; then
  echo "Usage: ${0} <image_under_test> [gae_deployment_version]"
  exit 1
fi

# for local tests it makes sense sometimes to pin the deployment to an
# active version as that will speed up the deployment, for CI/CD this feature
# is not recommended
readonly gaeDeploymentVersion=$2
if [ "${gaeDeploymentVersion}" ]; then
    DEPLOYMENT_OPTS="-v $gaeDeploymentVersion --no-promote"
    DEPLOYMENT_VERSION_URL_PREFIX="$gaeDeploymentVersion-dot-"

fi

# build the test app
pushd $testAppDir
mvn clean package -Ddeployment.token="${DEPLOYMENT_TOKEN}" -DskipTests --batch-mode
popd

# deploy to app engine
pushd $deployDir
export STAGING_IMAGE=$imageUnderTest
envsubst < Dockerfile.in > Dockerfile
echo "Deploying to App Engine: gcloud app deploy -q ${DEPLOYMENT_OPTS}"
gcloud app deploy -q ${DEPLOYMENT_OPTS}
popd

DEPLOYED_APP_URL="http://${DEPLOYMENT_VERSION_URL_PREFIX}$(gcloud app describe | grep defaultHostname | awk '{print $2}')"

echo "App deployed to URL: $DEPLOYED_APP_URL, making sure it accepts connections..."
# sometimes AppEngine deploys, returns the URL and then serves 502 errors, this was introduced to wait for that to be resolved
until [[ $(curl --silent --fail "$DEPLOYED_APP_URL/deployment.token" | grep "$DEPLOYMENT_TOKEN") ]]; do
  sleep 2
done


echo "Success pinging app! Output: "
echo "-----"
curl -s "${DEPLOYED_APP_URL}"
echo ""
echo "Deployment token: $DEPLOYMENT_TOKEN"
echo "-----"

echo "Running integration tests on application that is deployed at $DEPLOYED_APP_URL"

# run in cloud container builder
gcloud container builds submit \
  --config $dir/integration_test.yaml \
  --substitutions "_DEPLOYED_APP_URL=$DEPLOYED_APP_URL" \
  $dir

