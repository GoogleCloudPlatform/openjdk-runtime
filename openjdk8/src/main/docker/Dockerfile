# Copyright 2014 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ${docker.appengine.image}
ENV DEBIAN_FRONTEND noninteractive

# Create env vars to identify image
ENV OPENJDK_VERSION ${openjdk.version}
ENV GAE_IMAGE_NAME ${project.artifactId}
ENV GAE_IMAGE_LABEL ${docker.tag.long}

RUN \
 apt-get -q update \
 && apt-get -y -q --no-install-recommends install \
    # install the jdk and its dependencies
    ca-certificates-java \
    openjdk-${openjdk.version.major}-jdk-headless=${openjdk.version}'*' \
    # procps is used in the jvm shutdown hook
    procps \
    # other system utilities
    netbase \
    wget \
    unzip \

 # cleanup package manager caches
 && apt-get clean \
 && rm /var/lib/apt/lists/*_*

# Below code is a temporary fix to patch a bug  and address b/244448607.
# It should be removed once openjdk-8-8u342-b07-1 is promoted to stable (strech) debian package source.
ARG JAVA_PATCH_SRC=/tmp/java/src
ARG JAVA_PATCH_OUTPUT=/tmp/java/output
ARG JAVA_PATCH_BACKUP=/tmp/java/backup
ARG ORIG_RT_JAR_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/rt.jar

RUN mkdir -p $JAVA_PATCH_SRC \
    && mkdir -p $JAVA_PATCH_OUTPUT \
    && mkdir -p $JAVA_PATCH_BACKUP

# COPY patched files
COPY ConstantPoolGen.java $JAVA_PATCH_SRC/com/sun/org/apache/bcel/internal/generic/
COPY ConstantPool.java $JAVA_PATCH_SRC/com/sun/org/apache/bcel/internal/classfile/

# Build and Replace
RUN cp $ORIG_RT_JAR_PATH $JAVA_PATCH_BACKUP/original_rt.jar \
    # Unpack existing rt.jar to the output folder (used as the base drop folder)
    && cd $JAVA_PATCH_OUTPUT \
    && jar xf /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/rt.jar \
    # Compile the patched files and drop them in the output folder
    && cd $JAVA_PATCH_SRC \
    && javac -d $JAVA_PATCH_OUTPUT -cp $ORIG_RT_JAR_PATH $(find * -name '*.java') \
    # Pack the output folder which now has the new patched classes
    && cd $JAVA_PATCH_OUTPUT \
    && jar cvf $JAVA_PATCH_BACKUP/new_rt.jar . \
    # Replace the live rt.jar with the new rt.jar
    && cp $JAVA_PATCH_BACKUP/new_rt.jar $ORIG_RT_JAR_PATH
    ## clean-up
    #&& rm -rf /tmp/java

# Add the Stackdriver Debugger libraries
ADD https://storage.googleapis.com/cloud-debugger/appengine-java/current/cdbg_java_agent.tar.gz /opt/cdbg/
# Add the Stackdriver Profiler libraries
ADD https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz /opt/cprof/
COPY docker-entrypoint.bash /
COPY setup-env.d /setup-env.d/
COPY shutdown/ /shutdown/
RUN tar Cxfvz /opt/cdbg /opt/cdbg/cdbg_java_agent.tar.gz --no-same-owner \
 && rm /opt/cdbg/cdbg_java_agent.tar.gz \
 && tar Cxfvz /opt/cprof /opt/cprof/profiler_java_agent.tar.gz --no-same-owner \
 && rm /opt/cprof/profiler_java_agent.tar.gz \
 && chmod +x /docker-entrypoint.bash /shutdown/*.bash /setup-env.d/*.bash \
 && mkdir /var/log/app_engine \
 && chmod go+rwx /var/log/app_engine

ENV APP_DESTINATION ${docker.application.destination}

ENTRYPOINT ["/docker-entrypoint.bash"]
CMD ["java", "-jar", "${docker.application.destination}"]
