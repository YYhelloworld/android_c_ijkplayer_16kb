#! /usr/bin/env bash
#
# Copyright (C) 2013-2014 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#--------------------
set -e

UNAME_S=$(uname -s)
UNAME_SM=$(uname -sm)
echo "build on $UNAME_SM"

echo "ANDROID_NDK=$ANDROID_NDK"

if [ -z "$ANDROID_NDK" ]; then
    echo "You must define ANDROID_NDK before starting."
    echo "They must point to your NDK directories."
    echo ""
    exit 1
fi

# Detect NDK version
IJK_NDK_REL=$(grep -o 'Pkg\.Revision\s*=\s*[0-9]*' $ANDROID_NDK/source.properties 2>/dev/null | cut -d "=" -f 2 | sed 's/[[:space:]]*//g')
echo "IJK_NDK_REL=$IJK_NDK_REL"

# Determine NDK host tag
case "$UNAME_S" in
    Darwin)
        IJK_NDK_HOST_TAG="darwin-x86_64"
        export IJK_MAKE_FLAG=-j`sysctl -n machdep.cpu.thread_count`
    ;;
    Linux)
        IJK_NDK_HOST_TAG="linux-x86_64"
        if which nproc >/dev/null; then
            export IJK_MAKE_FLAG=-j`nproc`
        fi
    ;;
    CYGWIN_NT-*)
        IJK_NDK_HOST_TAG="windows-x86_64"
        IJK_WIN_TEMP="$(cygpath -am /tmp)"
        export TEMPDIR=$IJK_WIN_TEMP/
        echo "Cygwin temp prefix=$IJK_WIN_TEMP/"
    ;;
    *)
        echo "Unsupported OS: $UNAME_S"
        exit 1
    ;;
esac

# NDK toolchain path
export IJK_NDK_TOOLCHAIN_PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/$IJK_NDK_HOST_TAG
export IJK_NDK_SYSROOT=$IJK_NDK_TOOLCHAIN_PATH/sysroot
export IJK_NDK_BIN=$IJK_NDK_TOOLCHAIN_PATH/bin

echo "IJK_NDK_TOOLCHAIN_PATH=$IJK_NDK_TOOLCHAIN_PATH"
echo "IJK_NDK_SYSROOT=$IJK_NDK_SYSROOT"
echo "IJK_NDK_BIN=$IJK_NDK_BIN"

# Export common toolchain variables
export IJK_MAKE_FLAG
export IJK_NDK_REL
export IJK_NDK_HOST_TAG

echo "NDK $IJK_NDK_REL detected, using llvm Clang toolchain"