# Developing

This document contains instructions on how to build and test this image.

# Building the image

### Local build
To build the image you need git, docker (your user needs to be part of the ``docker`` group to run docker without sudo) and maven installed:
```
$ git clone https://github.com/GoogleCloudPlatform/openjdk-runtime.git
$ cd openjdk-runtime

# build all images
$ mvn clean install

# only build the openjdk:8 image
$ mvn clean install --also-make --projects openjdk8

# only build the openjdk:11 image
$ mvn clean install --also-make --projects openjdk11
```
These commands build the `openjdk` image with tags for each JDK version (`openjdk:8` and `openjdk:11`).

### Cloud build
To build using the [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/overview), 
you need to have the [Google Cloud SDK](https://cloud.google.com/sdk/) installed locally. We provide a script to make this more convenient.
```
# the following commands will build and push an image named "gcr.io/my-project/openjdk:8"
$ PROJECT_ID=my-project
$ MODULE_TO_BUILD=openjdk8 # only builds the openjdk:8 image
$ ./scripts/build.sh -p $PROJECT_ID -m $MODULE_TO_BUILD
```

If you would like to simulate the cloud build locally, pass in the `--local` argument.
```
$ PROJECT_ID=my-project
$ MODULE_TO_BUILD=openjdk8 # only builds the openjdk:8 image
$ ./scripts/build.sh -p $PROJECT_ID -m $MODULE_TO_BUILD --local
```

The configured Cloud Build execution will build the OpenJDK docker container, then create and teardown various GCP resources for integration testing. 
Before running, make sure you have done all of the following:

* enabled the Cloud Container Builder API
* initialized App Engine for your GCP project (run `gcloud app create`), and successfully deployed at least once
* provided the Container Builder Service account (cloudbuild.gserviceaccount.com) with the appropriate permissions needed to deploy App Engine applications and create GKE clusters.
* This includes at least the "App Engine Admin" and "Cloud Container Builder" roles, but simply adding the "Project Editor" role works fine as well.

# Running Tests
Integration tests can be run via [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/overview).
These tests deploy a sample test application to App Engine and to Google Kubernetes Engine using the provided runtime image, and
exercise various integrations with other GCP services. Note that the image under test must be pushed 
to a gcr.io repository before the integration tests can run.

```bash
$ RUNTIME_IMAGE=gcr.io/my-project-id/openjdk:my-tag
$ gcloud docker -- push $RUNTIME_IMAGE
```

**Run ALL integration tests (Local Docker, App Engine, Google Kubernetes Engine):**
```bash
$ ./scripts/integration_test.sh $RUNTIME_IMAGE
```

**Run ONLY Local Docker integration tests:**
```bash
$ ./scripts/local_runtimes_common_integration_test.sh $RUNTIME_IMAGE
```

**Run ONLY Local shutdown tests:**
```bash
$ ./scripts/local_shutdown_test.sh $RUNTIME_IMAGE
```


**Run ONLY App Engine flexible environment integration tests:**
```bash
$ ./scripts/ae_integration_test.sh $RUNTIME_IMAGE
```

**Run ONLY Kubernetes Engine (GKE) integration tests:**
```bash
$ ./scripts/gke_integration_test.sh $RUNTIME_IMAGE
```
