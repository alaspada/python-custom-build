#!/usr/bin/env bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="${THIS_DIR}/.."
LD_LIBRARY_PATH=${ROOT_DIR}/lib

LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${ROOT_DIR}/bin/python3.9 $@