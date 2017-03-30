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
To build using the [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/overview), you need to have the [Google Cloud SDK](https://cloud.google.com/sdk/) installed locally.
```
$ PROJECT_ID=my-project
$ ./scripts/cloudbuild.sh gcr.io/$PROJECT_ID/openjdk
```

If you would like to simulate the cloud build locally, pass in the `--local` argument.
```
$ PROJECT_ID=my-project
$ ./scripts/cloudbuild.sh gcr.io/$PROJECT_ID/openjdk --local
```

# Running Tests
Integration tests can be run via [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/overview).
These tests deploy a sample test application to App Engine using the provided runtime image, and 
exercise various integrations with other GCP services. Note that the image under test must be pushed 
to a gcr.io repository before the integration tests can run.
```bash
$ RUNTIME_IMAGE=gcr.io/my-project-id/openjdk:my-tag
$ gcloud docker -- push $RUNTIME_IMAGE
$ ./scripts/integration_test.sh $RUNTIME_IMAGE
```

