#!/bin/sh

set -e

# Runs integration tests on a given runtime image

dir=`dirname $0`
projectRoot=$dir/..
testAppDir=$projectRoot/test-application
deployDir=$testAppDir/target/deploy

imageUnderTest=$1

if [ -z "${imageUnderTest}" ]; then
  echo "Usage: ${0} <image_under_test>"
  exit 1
fi

# build the test app
pushd $testAppDir
mvn clean install
popd

# deploy to app engine
pushd $deployDir
export STAGING_IMAGE=$imageUnderTest
envsubst < Dockerfile.in > Dockerfile
echo "Deploying to App Engine with dockerfile:"
cat Dockerfile
gcloud app deploy -q
popd

DEPLOYED_APP_URL="http://$(gcloud app describe | grep defaultHostname | awk '{print $2}')"
echo "Running integration tests on application that is deployed at $DEPLOYED_APP_URL"

# run integration tests on the deployed app
gcloud container builds submit \
  --config $dir/integration_test.yaml \
  --substitutions "_DEPLOYED_APP_URL=$DEPLOYED_APP_URL" \
  $dir
