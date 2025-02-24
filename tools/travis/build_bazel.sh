#!/usr/bin/env bash
# Copyright 2018, OpenCensus Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e
set -x

# Limit memory.
export BAZEL_OPTIONS="--local_resources=4096,2,1.0"

# Limit the amount of progress output. We can't use --noshow_progress because
# Travis terminates the build after 10 mins without output.
export BAZEL_OPTIONS="$BAZEL_OPTIONS --experimental_ui_actions_shown=1"

# Enable thread safety analysis (only works with clang).
if [[ "$TRAVIS_COMPILER" = "clang" ]]; then
  export BAZEL_OPTIONS="$BAZEL_OPTIONS --copt=-Werror=thread-safety --copt=-Werror=thread-safety-reference"
fi

export BAZEL_VERSION="0.24.1"

wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-${BAZEL_OS}-x86_64.sh
chmod +x bazel-${BAZEL_VERSION}-installer-${BAZEL_OS}-x86_64.sh
./bazel-${BAZEL_VERSION}-installer-${BAZEL_OS}-x86_64.sh --user
echo "build --disk_cache=$HOME/bazel-cache" > ~/.bazelrc
echo "build --experimental_strict_action_env" >> ~/.bazelrc
du -sk $HOME/bazel-cache || true

bazel build $BAZEL_OPTIONS -k //...
bazel test $BAZEL_OPTIONS -k $(bazel query "kind(test, //...) except attr('tags', 'manual|noci', //...)")

du -sk $HOME/bazel-cache || true
