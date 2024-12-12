
# Google Cloud Platform OpenJDK Docker Image

This repository contains the source for the Google-maintained OpenJDK [docker](https://docker.com) image. This image can be used as the base image for running Java applications on [Google App Engine Flexible Environment](https://cloud.google.com/appengine/docs/flexible/java/) and [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine).

## Repository/Tag Details
Supported images/tags include:
* `gcr.io/google-appengine/openjdk:8`

## App Engine Flexible Environment
When using App Engine Flexible, you can use the runtime without worrying about Docker by specifying `runtime: java` in your `app.yaml`:
```yaml
runtime: java
env: flex
```
The runtime image `gcr.io/google-appenine/openjdk:8` will be automatically selected if you are attempting to deploy a JAR (`*.jar` file).

To select a jdk version, use the `runtime_config.jdk` field in app.yaml. Supported JDK versions include `openjdk8` and `openjdk11`.
```yaml
runtime: java
env: flex
runtime_config:
  jdk: openjdk8
```

If you want to use the image as a base for a custom runtime, you can specify `runtime: custom` in your `app.yaml` and then
write the Dockerfile like this:

```dockerfile
FROM gcr.io/google-appengine/openjdk
COPY your-application.jar $APP_DESTINATION
```

That will add the JAR in the correct location for the Docker container.

Once you have this configuration, you can use the Google Cloud SDK to deploy this directory containing the 2 configuration files and the JAR using:
```
gcloud app deploy app.yaml
```

## Kubernetes Engine & other Docker hosts
For other Docker hosts, you'll need to create a Dockerfile based on this image that copies your application code and installs dependencies. For example:

```dockerfile
FROM gcr.io/google-appengine/openjdk
COPY your-application.jar $APP_DESTINATION
```
You can then build the docker container using `docker build` or [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/).
By default, the CMD is set to run the application JAR. You can change this by specifying your own `CMD` or `ENTRYPOINT`.

### Container Memory Limits
The runtime will try to detect the container memory limit by looking at the `/sys/fs/cgroup/memory/memory.limit_in_bytes`  file, which is automatically mounted by Docker. However, this may not work with other container runtimes. In those cases, to help the runtime compute accurate JVM memory defaults when running on Kubernetes, you can indicate memory limit through the [Downward API](https://kubernetes.io/docs/tasks/configure-pod-container/environment-variable-expose-pod-information).

To do so add an environment variable named `KUBERNETES_MEMORY_LIMIT` *(This name is subject to change)* with the value `limits.memory` and the name of your container.
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
The entry point for the openjdk8 image is [docker-entrypoint.bash](https://github.com/GoogleCloudPlatform/openjdk-runtime/blob/master/openjdk-common/src/main/docker/docker-entrypoint.bash), which does the processing of the passed command line arguments to look for an executable alternative or arguments to the default command (java).

If the default command (java) is used, then the entry point sources the [setup-env.d/](https://github.com/GoogleCloudPlatform/openjdk-runtime/tree/master/openjdk-common/src/main/docker/setup-env.d), which looks for supported features to be enabled and/or configured.  The following table indicates the environment variables that may be used to enable/disable/configure features, any default values if they are not set:

|Env Var                             | Description         | Type     | Default                                     |
|------------------------------------|---------------------|----------|---------------------------------------------|
|`PROFILER_ENABLE`                   | Stackdriver Profiler| boolean  | `false`                                     |
|`TMPDIR`                            | Temporary Directory | dirname  |                                             |
|`JAVA_TMP_OPTS`                     | JVM tmpdir args     | JVM args | `-Djava.io.tmpdir=${TMPDIR}`                |
|`GAE_MEMORY_MB`                     | Available memory    | size     | Set by GAE or `/proc/meminfo`-400M          |
|`HEAP_SIZE_RATIO`                   | Memory for the heap | percent  | 80                                          |
|`HEAP_SIZE_MB`                      | Available heap      | size     | `${HEAP_SIZE_RATIO}`% of `${GAE_MEMORY_MB}` |
|`JAVA_HEAP_OPTS`                    | JVM heap args       | JVM args | `-Xms${HEAP_SIZE_MB}M -Xmx${HEAP_SIZE_MB}M` |
|`JAVA_GC_OPTS`                      | JVM GC args         | JVM args | `-XX:+UseG1GC` plus configuration           |
|`JAVA_USER_OPTS`                    | JVM other args      | JVM args |                                             |
|`JAVA_OPTS`                         | JVM args            | JVM args | See below                                   |
|`SHUTDOWN_LOGGING_THREAD_DUMP`      | Shutdown thread dump| boolean  | `false`                                     |
|`SHUTDOWN_LOGGING_HEAP_INFO`        | Shutdown heap info  | boolean  | `false`                                     |
|`SHUTDOWN_LOGGING_SAMPLE_THRESHOLD` | Shutdown sampling   | percent  | 100                                         |

If not explicitly set, `JAVA_OPTS` is defaulted to 
```
JAVA_OPTS:=-showversion \
           ${JAVA_TMP_OPTS} \
           ${PROFILER_AGENT} \
           ${JAVA_HEAP_OPTS} \
           ${JAVA_GC_OPTS} \
           ${JAVA_USER_OPTS}
```

The command line executed is effectively (where $@ are the args passed into the docker entry point):
```
java $JAVA_OPTS "$@"
```

### JVM Shutdown Diagnostics

This feature is not enabled by default.

Sometimes it's necessary to obtain diagnostic information when the JVM is stopped using `SIGTERM` or `docker stop`.
This may happen on App Engine flexible environment, when the autohealer decides to kill unhealthy VMs that have
an app that is unresponsive due to a deadlock or high load and stopped returning requests, including health checks.

To help diagnose such situations the runtime provides support for outputting a thread dump and/or
heap info upon JVM shutdown forced by the `TERM` signal.

The following environment variables should be used to enable app container shutdown reporting (must be set to `true` or `false`):

`SHUTDOWN_LOGGING_THREAD_DUMP` - output thread dump

`SHUTDOWN_LOGGING_HEAP_INFO` - output heap information

If enabled, the runtime provides a wrapper for the JVM that traps `SIGTERM`, and runs debugging tools on the JVM
to emit the thread dump and heap information to stdout.

If you're running many VMs, sampling is supported by using the environment variable `SHUTDOWN_LOGGING_SAMPLE_THRESHOLD`
which is an integer between 0 and 100. 0 means no VMs report logs, 100 means all VMs report logs.
(If this env var is not set, we default to reporting for all VMs).

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
