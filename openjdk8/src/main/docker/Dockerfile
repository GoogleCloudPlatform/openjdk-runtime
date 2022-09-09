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
    # procps is used in the jvm shutdown hook
    procps \
    # other system utilities
    netbase \
    wget \
    unzip \
    fontconfig \
    locales \

 # cleanup package manager caches
 && apt-get clean \
 && rm /var/lib/apt/lists/*_*

ARG OPENJDK_VER='jdk8u345-b01'
ARG OPENJDK_VER_NAME='8u345b01'
ARG OPENJDK_TEMP_PATH='/tmp/openjdk'
ARG OPENJDK_OUT='/usr/lib/openjdk'
ENV PATH $OPENJDK_OUT/bin:$PATH
ENV JAVA_HOME $OPENJDK_OUT

RUN mkdir -p $OPENJDK_TEMP_PATH \
 && mkdir -p $OPENJDK_OUT \
 && wget -O $OPENJDK_TEMP_PATH/openjdk.tar.gz https://github.com/adoptium/temurin8-binaries/releases/download/$OPENJDK_VER/OpenJDK8U-jdk_x64_linux_hotspot_$OPENJDK_VER_NAME.tar.gz \
 && tar Cxfvz --file $OPENJDK_TEMP_PATH/openjdk.tar.gz --directory $OPENJDK_TEMP_PATH --no-same-owner \
 && rm $OPENJDK_TEMP_PATH/openjdk.tar.gz \
 && cp -r $OPENJDK_TEMP_PATH/$OPENJDK_VER/* $OPENJDK_OUT \
 && rm -rf $OPENJDK_TEMP_PATH \
 && ln -s $OPENJDK_OUT/bin/* /usr/local/bin/

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
