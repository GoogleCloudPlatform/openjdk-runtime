#!/bin/bash

JAVA_MAJOR_VERSION=7

POSSIBLE_JAVA_PKGS=`apt-cache dump | grep -E '(java|jre|jdk)' | grep Package | grep $JAVA_MAJOR_VERSION | awk '{ print $2 }'`
for PKG in $POSSIBLE_JAVA_PKGS;
  do
   apt list | grep $PKG && echo "NOT OK. $PKG is installed" || echo "OK. $PKG is not installed"
  done
