# Developing

This document contains instructions on how to build and test this image.

# Building the image

### Local build
To build the image you need git, docker and maven installed:
```
$ git clone https://github.com/GoogleCloudPlatform/openjdk-runtime.git
$ cd openjdk-runtime
$ mvn clean install
```
The resulting image is called openjdk

### Cloud build
To build using the [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/overview), 
you need to have the [Google Cloud SDK](https://cloud.google.com/sdk/) installed locally. We provide a script to make this more convenient.
```
# the following commands will build and push an image named "gcr.io/my-project/openjdk:tag"
$ PROJECT_ID=my-project
$ TAG=tag
$ ./scripts/build.sh gcr.io/$PROJECT_ID $TAG
```

If you would like to simulate the cloud build locally, pass in the `--local` argument.
```
$ PROJECT_ID=my-project
$ TAG=tag
$ ./scripts/build.sh gcr.io/$PROJECT_ID $TAG --local
```

# Running Tests
Integration tests can be run via [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/overview).
These tests deploy a sample test application to App Engine and to Google Container Engine using the provided runtime image, and
exercise various integrations with other GCP services. Note that the image under test must be pushed 
to a gcr.io repository before the integration tests can run.
```bash
$ RUNTIME_IMAGE=gcr.io/my-project-id/openjdk:my-tag
$ gcloud docker -- push $RUNTIME_IMAGE
$ ./scripts/integration_test.sh $RUNTIME_IMAGE
```

You also have the possibility to run the tests only on App Engine or only on Google Container Engine.

* For App Engine:
```bash
$ ./scripts/ae_integration_test.sh $RUNTIME_IMAGE
```

* For Google Container Engine:
```bash
$ ./scripts/gke_integration_test.sh $RUNTIME_IMAGE
```