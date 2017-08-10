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

# only build the openjdk8 image
$ mvn clean install -am -pl openjdk8

# only build the openjdk9 image
$ mvn clean install -am -pl openjdk9
```
The resulting image(s) are called openjdk.

### Cloud build
To build using the [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/overview), 
you need to have the [Google Cloud SDK](https://cloud.google.com/sdk/) installed locally. We provide a script to make this more convenient.
```
# the following commands will build and push an image named "gcr.io/my-project/openjdk:8"
$ PROJECT_ID=my-project
$ MODULE_TO_BUILD=openjdk8 # only builds the openjdk:8 image
$ ./scripts/build.sh -d gcr.io/$PROJECT_ID -m $MODULE_TO_BUILD
```

If you would like to simulate the cloud build locally, pass in the `--local` argument.
```
$ PROJECT_ID=my-project
$ MODULE_TO_BUILD=openjdk8 # only builds the openjdk:8 image
$ ./scripts/build.sh -d gcr.io/$PROJECT_ID -m $MODULE_TO_BUILD --local
```

# Running Tests
Integration tests can be run via [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/overview).
These tests deploy a sample test application to App Engine and to Google Container Engine using the provided runtime image, and
exercise various integrations with other GCP services. Note that the image under test must be pushed 
to a gcr.io repository before the integration tests can run.

```bash
$ RUNTIME_IMAGE=gcr.io/my-project-id/openjdk:my-tag
$ gcloud docker -- push $RUNTIME_IMAGE
```

**Run ALL integration tests (Local Docker, App Engine, Google Container Engine):**
```bash
$ ./scripts/integration_test.sh $RUNTIME_IMAGE
```

**Run ONLY Local Docker integration tests:**
```bash
$ ./scripts/local_integration_test.sh $RUNTIME_IMAGE
```

**Run ONLY App Engine flexible environment integration tests:**
```bash
$ ./scripts/ae_integration_test.sh $RUNTIME_IMAGE
```

**Run ONLY Container Engine (GKE) integration tests:**
```bash
$ ./scripts/gke_integration_test.sh $RUNTIME_IMAGE
```
