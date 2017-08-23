#!/bin/bash

is_true() {
  # case insensitive check for "true"
  if [[ ${1,,} = "true" ]]; then
    true
  else
    false
  fi
}
