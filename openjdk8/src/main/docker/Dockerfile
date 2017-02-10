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
ENV GAE_IMAGE_LABEL ${docker.tag.prefix}${openjdk.version}-${maven.build.timestamp}

# Update debian 
RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list \
 && apt-get -q update \
 && apt-get -y -q --no-install-recommends install \
    ca-certificates-java=20161107'*' \
    openjdk-8-jdk-headless=${openjdk.version}'-*' \
    netbase \
    wget \ 
    unzip \
 && apt-get clean \
 && rm /var/lib/apt/lists/*_*

# Add the cloud debugger libraries
ADD https://storage.googleapis.com/cloud-debugger/appengine-java/current/cdbg_java_agent.tar.gz /opt/cdbg/
COPY docker-entrypoint.bash /
COPY setup-env.bash /
COPY shutdown-wrapper.bash /
RUN tar Cxfvz /opt/cdbg /opt/cdbg/cdbg_java_agent.tar.gz --no-same-owner \
 && rm /opt/cdbg/cdbg_java_agent.tar.gz \
 && chmod +x /docker-entrypoint.bash /setup-env.bash /shutdown-wrapper.bash \
 && mkdir /var/log/app_engine \
 && chmod go+rwx /var/log/app_engine

ENTRYPOINT ["/docker-entrypoint.bash"]
CMD ["java", "-jar", "app.jar"]
