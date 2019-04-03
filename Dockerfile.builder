FROM gcr.io/cloud-builders/javac
ARG MAVEN_VERSION=3.5.0
ARG USER_HOME_DIR="/root"
ARG SHA=beb91419245395bd69a4a6edad5ca3ec1a8b64e41457672dc687c173a495f034
ARG BASE_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update -qqy && apt-get install -qqy curl \
  && mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-$MAVEN_VERSION-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
  # clean up build packages
  && apt-get remove -qqy --purge curl \
  && rm /var/lib/apt/lists/*_*

ENV M2_HOME /usr/share/maven

ENTRYPOINT ["mvn"]