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
$ ./scripts/cloudbuild.sh
```