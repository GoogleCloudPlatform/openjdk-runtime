# Google Cloud Platform OpenJDK Docker Image

This repository contains the source for the Google-maintained OpenJDK [docker](https://docker.com) image. This image can be used as the base image for running Java applications on [Google App Engine Flexible Environment](https://cloud.google.com/appengine/docs/flexible/java/) and [Google Container Engine](https://cloud.google.com/container-engine).

This image is mirrored at both `launcher.gcr.io/google/openjdk8` and `gcr.io/google-appengine/openjdk`.

## App Engine Flexible Environment
When using App Engine Flexible, you can use the runtime without worrying about Docker by specifying `runtime: java` in your `app.yaml`:
```yaml
runtime: java
env: flex
```
The runtime image `gcr.io/google-appenine/openjdk` will be automatically selected if you are attempting to deploy a JAR (`*.jar` file).

If you want to use the image as a base for a custom runtime, you can specify `runtime: custom` in your `app.yaml` and then
write the Dockerfile like this:

```dockerfile
FROM gcr.io/google-appengine/openjdk
COPY your-application.jar app.jar
```
      
That will add the JAR in the correct location for the Docker container.
      
Once you have this configuration, you can use the Google Cloud SDK to deploy this directory containing the 2 configuration files and the JAR using:
```
gcloud app deploy app.yaml
```

## Container Engine & other Docker hosts
For other Docker hosts, you'll need to create a Dockerfile based on this image that copies your application code and installs dependencies. For example:

```dockerfile
FROM gcr.io/google-appengine/openjdk
COPY your-application.jar app.jar
```
You can then build the docker container using `docker build` or [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/).
By default, the CMD is set to run the application JAR. You can change this by specifying your own `CMD` or `ENTRYPOINT`.

### Container Memory Limits
To help the runtime compute accurate JVM memory defaults when running on Kubernetes, you can indicate memory limit through the [Downward API](https://kubernetes.io/docs/tasks/configure-pod-container/environment-variable-expose-pod-information).

To do so add an environment variable named `KUBERNETES_MEMORY_LIMIT` with the value `limits.memory` and the name of your container.
For example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-envars-resourcefieldref
spec:
  containers:
    - name: java-kubernetes-container
      image: gcr.io/google-appengine/openjdk
      resources:
        requests:
          memory: "32Mi"
        limits:
          memory: "64Mi"
      env:
        - name: KUBERNETES_MEMORY_LIMIT
          valueFrom:
            resourceFieldRef:
              containerName: java-kubernetes-container
              resource: limits.memory
```

## The Default Entry Point
Any arguments passed to the entry point that are not executable are treated as arguments to the java command:
```
$ docker run openjdk -jar /usr/share/someapplication.jar
```

Any arguments passed to the entry point that are executable replace the default command, thus a shell could
be run with:
```
> docker run -it --rm openjdk bash
root@c7b35e88ff93:/# 
```

## Entry Point Features
The entry point for the openjdk8 image is [docker-entrypoint.bash](https://github.com/GoogleCloudPlatform/openjdk-runtime/blob/master/openjdk8/src/main/docker/docker-entrypoint.bash), which does the processing of the passed command line arguments to look for an executable alternative or arguments to the default command (java).

If the default command (java) is used, then the entry point sources the [setup-env.bash](https://github.com/GoogleCloudPlatform/openjdk-runtime/blob/master/openjdk8/src/main/docker/setup-env.bash), which looks for supported features to be enabled and/or configured.  The following table indicates the environment variables that may be used to enable/disable/configure features, any default values if they are not set: 

|Env Var           | Description         | Type     | Default                                     |
|------------------|---------------------|----------|---------------------------------------------|
|`DBG_ENABLE`      | Stackdriver Debugger| boolean  | `true`                                      |
|`TMPDIR`          | Temporary Directory | dirname  |                                             |
|`JAVA_TMP_OPTS`   | JVM tmpdir args     | JVM args | `-Djava.io.tmpdir=${TMPDIR}`                |
|`GAE_MEMORY_MB`   | Available memory    | size     | Set by GAE or `/proc/meminfo`-400M          |
|`HEAP_SIZE_RATIO` | Memory for the heap | percent  | 80                                          |
|`HEAP_SIZE_MB`    | Available heap      | size     | `${HEAP_SIZE_RATIO}`% of `${GAE_MEMORY_MB}` |
|`JAVA_HEAP_OPTS`  | JVM heap args       | JVM args | `-Xms${HEAP_SIZE_MB}M -Xmx${HEAP_SIZE_MB}M` |
|`JAVA_GC_OPTS`    | JVM GC args         | JVM args | `-XX:+UseG1GC` plus configuration           |
|`JAVA_USER_OPTS`  | JVM other args      | JVM args |                                             |
|`JAVA_OPTS`       | JVM args            | JVM args | See below                                   |

If not explicitly set, `JAVA_OPTS` is defaulted to 
```
JAVA_OPTS:=-showversion \
           ${JAVA_TMP_OPTS} \
           ${DBG_AGENT} \
           ${JAVA_HEAP_OPTS} \
           ${JAVA_GC_OPTS} \
           ${JAVA_USER_OPTS}
```

The command line executed is effectively (where $@ are the args passed into the docker entry point):
```
java $JAVA_OPTS "$@"
```

## The Default Command
The default command will attempt to run `app.jar` in the current working directory.
It's equivalent to:
```
$ docker run openjdk java -jar app.jar
Error: Unable to access jarfile app.jar
```
The error is normal because the default command is designed for child containers that have a Dockerfile definition like this:
```
FROM openjdk
ADD my_app_0.0.1.jar app.jar
```
# Development Guide

* See [instructions](DEVELOPING.md) on how to build and test this image.

# Contributing changes

* See [CONTRIBUTING.md](CONTRIBUTING.md)

## Licensing

* See [LICENSE.md](LICENSE)
