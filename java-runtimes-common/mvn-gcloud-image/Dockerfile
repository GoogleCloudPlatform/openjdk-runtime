# Dockerfile for building a test container that includes java, maven, and the Google Cloud SDK.
# This is intended to be used as part of a Google Cloud Container Builder build.

FROM gcr.io/cloud-builders/mvn:3.3.9-jdk-8

ARG CLOUD_SDK_VERSION=172.0.0

RUN apt-get -y update && \
    apt-get -y install gcc python2.7 python-dev python-setuptools curl wget ca-certificates gettext-base && \

    # Setup Google Cloud SDK (latest)
    mkdir -p /builder && \
    wget -qO- "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" | tar zxv -C /builder && \
    CLOUDSDK_PYTHON="python2.7" /builder/google-cloud-sdk/install.sh \
        --usage-reporting=false \
        --bash-completion=false \
        --disable-installation-options && \

    /builder/google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check 1 && \

    # Kubernetes configuration
    /builder/google-cloud-sdk/bin/gcloud config set compute/zone us-east1-b && \
    /builder/google-cloud-sdk/bin/gcloud components install kubectl -q

ENV PATH=/builder/google-cloud-sdk/bin/:$PATH
