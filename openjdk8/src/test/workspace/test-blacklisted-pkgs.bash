#!/bin/bash

BLACKLIST="jvm-7-avian-jre"
BLACKLIST="java7-runtime-headless $BLACKLIST"
BLACKLIST="python2.7-pyjavaproperties $BLACKLIST"
BLACKLIST="libjsr107cache-java $BLACKLIST"
BLACKLIST="libbiojava1.7-java $BLACKLIST"
BLACKLIST="oracle-java7-installer $BLACKLIST"
BLACKLIST="oracle-java7-jdk $BLACKLIST"
BLACKLIST="openjdk-7-jre-zero $BLACKLIST"
BLACKLIST="sun-java7-jre $BLACKLIST"
BLACKLIST="java7-sdk $BLACKLIST"
BLACKLIST="libdb4.7-java-dev $BLACKLIST"
BLACKLIST="openjdk-7-jdk $BLACKLIST"
BLACKLIST="java7-sdk-headless $BLACKLIST"
BLACKLIST="openjdk-7-jre-headless $BLACKLIST"
BLACKLIST="java7-runtime $BLACKLIST"
BLACKLIST="libtomcat7-java $BLACKLIST"
BLACKLIST="openjdk-7-dbg $BLACKLIST"
BLACKLIST="openjdk-7-jre-dcevm $BLACKLIST"
BLACKLIST="openjdk-7-jre-lib $BLACKLIST"
BLACKLIST="uwsgi-plugin-jvm-openjdk-7 $BLACKLIST"
BLACKLIST="openjdk-7-jre $BLACKLIST"
BLACKLIST="openjdk-7-source $BLACKLIST"
BLACKLIST="icedtea-7-jre-jamvm $BLACKLIST"
BLACKLIST="openjdk-7-demo $BLACKLIST"
BLACKLIST="openjdk-7-doc $BLACKLIST"
BLACKLIST="libnb-platform7-devel-java $BLACKLIST"
BLACKLIST="uwsgi-plugin-jwsgi-openjdk-7 $BLACKLIST"

for PKG in $BLACKLIST;
  do
   dpkg -l | grep '^.i' | grep $PKG > /dev/null && echo "NOT OK. $PKG is installed" || echo "OK. $PKG is not installed"
  done
