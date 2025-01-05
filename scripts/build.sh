#!/bin/sh

set -eu

usage() {
    echo "usage: $(basename $0) VERSION"
    exit 1
}

[ "$#" -eq 1 ] || usage

export VERSION="$1"

OS=$(uname)

# # build universal MacOS binary
# sh $(dirname $0)/build_darwin.sh

# # # build arm64 and amd64 Linux binaries
# sh $(dirname $0)/build_linux.sh

# Build on macOS only
if [ "$OS" = "Darwin" ]; then
    echo "Building Ollama for macOS"
    sh "$(dirname "$0")/build_darwin.sh"
fi

# Build on Linux only
if [ "$OS" = "Linux" ]; then
    echo "Building Ollama for Linux"
    sh "$(dirname "$0")/build_linux.sh"
fi

# # build arm64 and amd64 Docker images
echo "Building Ollama Docker images"
sh $(dirname $0)/build_docker.sh
