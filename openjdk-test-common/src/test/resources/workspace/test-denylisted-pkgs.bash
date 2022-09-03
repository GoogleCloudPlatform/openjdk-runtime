#!/bin/bash

DENYLIST="\
jvm-7-avian-jre \
java7-runtime-headless \
python2.7-pyjavaproperties \
libjsr107cache-java \
libbiojava1.7-java \
oracle-java7-installer \
oracle-java7-jdk \
openjdk-7-jre-zero \
sun-java7-jre \
java7-sdk \
libdb4.7-java-dev \
openjdk-7-jdk \
java7-sdk-headless \
openjdk-7-jre-headless \
java7-runtime \
libtomcat7-java \
openjdk-7-dbg \
openjdk-7-jre-dcevm \
openjdk-7-jre-lib \
uwsgi-plugin-jvm-openjdk-7 \
openjdk-7-jre \
openjdk-7-source \
icedtea-7-jre-jamvm \
openjdk-7-demo \
openjdk-7-doc \
libnb-platform7-devel-java \
uwsgi-plugin-jwsgi-openjdk-7"


for PKG in $DENYLIST;
  do
   dpkg -l | grep '^.i' | grep $PKG > /dev/null && echo "NOT OK. $PKG is installed" || echo "OK. $PKG is not installed"
  done
