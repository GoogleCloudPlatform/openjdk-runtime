#!/bin/bash

is_true() {
  # case insensitive check for "true"
  if [[ ${1,,} = "true" ]]; then
    return ${true}
  else
    return ${false}
  fi
}
