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

# Setup environment for CI with GKE.
# This include:
# - Building a test application into a docker image
# - Upload the image to Google Container Registry
# - Create a Kubernetes cluster on GKE
# - Deploy the application
# - Run the integration test
set -e

readonly dir=$(dirname $0)
readonly projectRoot="$dir/.."
readonly testAppDir="$projectRoot/java-runtimes-common/test-spring-application"
readonly deployDir="$testAppDir/target/deploy"
readonly DEPLOYMENT_TOKEN=$(date -u +%Y-%m-%d-%H-%M-%S-%N)

# The $TAG was introduced to be able to reuse the existing cluster but force redeployment.
# Kubernetes' "kubectl apply -f" doesn't trigger a new deployment rollout unless there is a change in the yaml spec.
# See https://github.com/kubernetes/kubernetes/issues/33664 for the debate around this behavior.

if [ -z "${TAG}" ]; then
  export TAG="$(date -u +%Y-%m-%d_%H_%M)"
fi

readonly projectName=$(gcloud info \
                | awk '/^Project: / { print $2 }' \
                | sed 's/\[//'  \
                | sed 's/\]//')
readonly imageName="openjdk-gke-integration:$TAG"
readonly imageUrl="gcr.io/$projectName/$imageName"
readonly defaultZone="us-east1-c"

readonly imageUnderTest=$1
clusterName=$2
if [[ -z "$imageUnderTest" ]]; then
  echo "Usage: ${0} <image_under_test> [gke_cluster_name]"
  exit 1
fi

if [[ -z "$clusterName" ]]; then
 # generate random alpha string
 clusterName=$(head /dev/urandom | tr -dc 'a-z' | fold -w 20 | head -n 1)
 readonly tearDown="true"
fi

# build the test app
pushd ${testAppDir}
mvn clean install -Pruntime.custom -Dapp.deploy.image=$imageUnderTest -Ddeployment.token="${DEPLOYMENT_TOKEN}" -DskipTests --batch-mode
popd

# deploy to Google Kubernetes Engine
pushd ${deployDir}
export TESTED_IMAGE=${imageUrl}
envsubst < "openjdk-spring-boot.yaml.in" > "openjdk-spring-boot.yaml"

echo "Deploying image to Google Container Registry..."
gcloud docker -- build -t "$imageName" .
gcloud docker -- tag "$imageName" "$imageUrl"
gcloud docker -- push gcr.io/${projectName}/${imageName}

echo "Creating or searching for a Kubernetes cluster..."
TEST_CLUSTER_EXISTENCE=$(gcloud container clusters list --zone="$defaultZone" | awk "/$clusterName/")
if [ -z "$TEST_CLUSTER_EXISTENCE" ]; then
  gcloud container clusters create "$clusterName" --num-nodes=1 --disk-size=10 --zone="$defaultZone"
fi

echo "Deploying application to Google Kubernetes Engine..."
gcloud container clusters get-credentials ${clusterName} --zone="$defaultZone"
kubectl apply -f "openjdk-spring-boot.yaml"
popd

echo "Waiting for the application to be accessible (expected time: ~1min)"

# The load balancer service may take some time to expose the application
# (~ 2 min on the cluster creation)
until [[ $(curl --silent --fail "http://$DEPLOYED_APP_URL/deployment.token" | grep "$DEPLOYMENT_TOKEN") ]]; do
  sleep 5
  DEPLOYED_APP_URL=$(kubectl describe services openjdk-spring-boot \
                             | awk '/LoadBalancer Ingress/ { print $3 }')
  echo "Current URL for app: $DEPLOYED_APP_URL, deployment token: $DEPLOYMENT_TOKEN. Making sure it accepts connections..."
done

# run in cloud container builder
echo "Running integration tests on application that is deployed at $DEPLOYED_APP_URL"
gcloud builds submit \
  --config ${dir}/integration_test.yaml \
  --substitutions "_DEPLOYED_APP_URL=http://$DEPLOYED_APP_URL" \
  ${dir}

# teardown any resources we created
if [ "$tearDown" == "true" ]; then
  # run a cleanup build once tests have finished executing
  gcloud builds submit \
    --config $dir/gke_cluster_cleanup.yaml \
    --substitutions "_CLUSTER_NAME=$clusterName,_ZONE=$defaultZone" \
    --async \
    --no-source
fi
