#!/bin/bash

SOURCE_DIR=$1

if [ -z $SOURCE_DIR ]; then
  echo "USAGE: $0 <source_dir>"
  exit 1;
fi

# compile modules
javac -d out --module-source-path $SOURCE_DIR $(find $SOURCE_DIR -name '*.java')

# run main class
java --module-path out -m com.google.greetings/com.google.greetings.Main
