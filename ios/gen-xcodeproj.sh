#!/bin/bash

# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

set -e

SHELL_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "SHELL_DIR: ${SHELL_DIR}";

PWD=$(pwd)
cd ${SHELL_DIR}

CMAKE_FILE=${SHELL_DIR}/..
BUILD_PATH=${SHELL_DIR}/xcodeproj
TOOLCHAIN_FILE=${SHELL_DIR}/ios.toolchain.cmake

# CMAKE_CONFIGURATION_TYPES: https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-configurations
cmake -G Xcode ${CMAKE_FILE} -B ${BUILD_PATH} \
  -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE} \
  -DCMAKE_CONFIGURATION_TYPES="Debug;Release;" \
  -DDEPLOYMENT_TARGET=12.0 \
  -DPLATFORM=OS64COMBINED \

cd ${PWD}