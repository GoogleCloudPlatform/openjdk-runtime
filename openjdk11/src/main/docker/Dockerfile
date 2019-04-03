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
 # add debian stretch-backports repo in order to install openjdk11
 echo 'deb http://httpredir.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports.list \

 && apt-get -q update \
 && apt-get -y -q --no-install-recommends install \
    # install the jdk and its dependencies
    ca-certificates-java \
    openjdk-${openjdk.version.major}-jdk-headless=${openjdk.version}'*' \
    # procps is used in the jvm shutdown hook
    procps \
    # other system utilities
    netbase \
    unzip \
    wget \

 # cleanup package manager caches
 && apt-get clean \
 && rm /var/lib/apt/lists/*_*

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
