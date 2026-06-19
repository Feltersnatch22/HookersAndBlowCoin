#!/usr/bin/env bash

OS=${1}
GITHUB_WORKSPACE=${2}
GITHUB_REF=${3}
MATRIX_OS=${OS}

if [[ ! ${OS} || ! ${GITHUB_WORKSPACE} ]]; then
    echo "Error: Invalid options"
    echo "Usage: ${0} <operating system> <github workspace path>"
    exit 1
fi
echo "----------------------------------------"
echo "OS: ${MATRIX_OS}"
echo "----------------------------------------"

QT_BUILD=0
if [[ ${MATRIX_OS} == "windows-qt" ]]; then
    QT_BUILD=1
fi

if [[ ${OS} == "arm32v7-disable-wallet" || ${OS} == "linux-disable-wallet" || ${OS} == "aarch64-disable-wallet" ]]; then
    OS=`echo ${OS} | cut -d"-" -f1`
fi
if [[ ${OS} == "linux-qt" ]]; then
    OS=linux
fi
if [[ ${OS} == "windows-qt" ]]; then
    OS=windows
fi

echo "----------------------------------------"
echo "Building Dependencies for ${OS} (matrix=${MATRIX_OS})"
echo "----------------------------------------"

cd depends
if [[ ${OS} == "windows" ]]; then
    if [[ ${QT_BUILD} == "1" ]]; then
        make HOST=x86_64-w64-mingw32 -j2
    else
        make HOST=x86_64-w64-mingw32 NO_QT=1 -j2
    fi
elif [[ ${OS} == "osx" ]]; then
    echo "OSX building is not currently enabled"
    exit 1
elif [[ ${OS} == "linux" || ${OS} == "linux-disable-wallet" ]]; then
    make HOST=x86_64-linux-gnu NO_QT=1 -j2
elif [[ ${OS} == "arm32v7" || ${OS} == "arm32v7-disable-wallet" ]]; then
    make HOST=arm-linux-gnueabihf NO_QT=1 -j2
elif [[ ${OS} == "aarch64" || ${OS} == "aarch64-disable-wallet" ]]; then
    make HOST=aarch64-linux-gnu NO_QT=1 -j2
fi
