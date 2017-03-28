#!/bin/sh

set -e

dir=`dirname $0`
projectRoot=$dir/..
testAppDir=$projectRoot/test-application
deployDir=$testAppDir/target/deploy

## build test app
#pushd $testAppDir
#mvn clean install
#popd
#
## deploy to app engine
#pushd $deployDir
#export STAGING_IMAGE=gcr.io/google-appengine/openjdk # TODO this should be an arg to this script
#envsubst < Dockerfile.in > Dockerfile
#echo "Deploying with dockerfile:"
#cat Dockerfile
#gcloud app deploy -q
#popd

DEPLOYED_APP_URL="http://$(gcloud app describe | grep defaultHostname | awk '{print $2}')"
echo "Running integration tests on application that is deployed at $DEPLOYED_APP_URL"

# run integration tests on the deployed app
gcloud container builds submit \
  --config $dir/integration_test.yaml \
  --substitutions "_DEPLOYED_APP_URL=$DEPLOYED_APP_URL" \
  $deployDir
