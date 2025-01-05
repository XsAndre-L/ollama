#!/bin/sh

set -eu

export VERSION=${VERSION:-0.0.0}
export GOFLAGS="'-ldflags=-w -s \"-X=github.com/ollama/ollama/core/version.Version=$VERSION\" \"-X=github.com/ollama/ollama/core/server.mode=release\"'"

docker build \
    --push \
    --platform=linux/arm64,linux/amd64 \
    --build-arg=VERSION \
    --build-arg=GOFLAGS \
    -f Dockerfile \
    -t ollama/ollama -t ollama/ollama:$VERSION \
    .
