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
readonly testAppDir=$projectRoot/java-runtimes-common/test-spring-application
readonly deployDir=$testAppDir/target/deploy
readonly DEPLOYMENT_TOKEN=$(date -u +%Y-%m-%d-%H-%M-%S-%N)

readonly imageUnderTest=$1
if [ -z "${imageUnderTest}" ]; then
  echo "Usage: ${0} <image_under_test> [gae_deployment_version]"
  exit 1
fi

# If provided, pin to a specific version. Otherwise, generate a random new version ID to prevent
# inadvertent collisions.
gaeDeploymentVersion=$2
if [ -z "${gaeDeploymentVersion}" ]; then
  gaeDeploymentVersion=$(date -u +%Y-%m-%d-%H-%M-%S-%N)
  readonly tearDown="true"
fi
DEPLOYMENT_OPTS="-v $gaeDeploymentVersion --no-promote --no-stop-previous-version"
DEPLOYMENT_VERSION_URL_PREFIX="$gaeDeploymentVersion-dot-"

# build the test app
pushd $testAppDir
mvn clean install -Pruntime.custom -Dapp.deploy.image=$imageUnderTest -Ddeployment.token="${DEPLOYMENT_TOKEN}" -DskipTests --batch-mode
popd

# deploy to app engine
pushd $deployDir
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
gcloud builds submit \
  --config $dir/integration_test.yaml \
  --substitutions "_DEPLOYED_APP_URL=$DEPLOYED_APP_URL" \
  $dir

if [ "$tearDown" == "true" ]; then
  # run a cleanup build once tests have finished executing
  gcloud builds submit \
    --config $dir/integration_test_cleanup.yaml \
    --substitutions "_VERSION=$gaeDeploymentVersion" \
    --async \
    --no-source
fi

