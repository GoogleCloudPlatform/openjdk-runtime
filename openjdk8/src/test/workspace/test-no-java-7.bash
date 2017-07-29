#!/bin/bash

POSSIBLE_JAVA_7_PKGS=`apt-cache dump | grep -E '(java|jre|jdk)' | grep Package | grep 7 | awk '{ print $2 }'`
for PKG in $POSSIBLE_JAVA_7_PKGS;
  do
   apt list | grep $PKG || echo "OK. $PKG is not installed"
  done
