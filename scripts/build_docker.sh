# #!/bin/sh

# set -eu

# . $(dirname $0)/env.sh

# # Set PUSH to a non-empty string to trigger push instead of load
# PUSH=${PUSH:-""}

# if [ -z "${PUSH}" ] ; then
#     echo "Building ${FINAL_IMAGE_REPO}:$VERSION locally.  set PUSH=1 to push"
#     LOAD_OR_PUSH="--load"
# else
#     echo "Will be pushing ${FINAL_IMAGE_REPO}:$VERSION"
#     LOAD_OR_PUSH="--push"
# fi

# docker buildx build \
#     ${LOAD_OR_PUSH} \
#     --platform=${PLATFORM} \
#     ${OLLAMA_COMMON_BUILD_ARGS} \
#     -f Dockerfile \
#     -t ${FINAL_IMAGE_REPO}:$VERSION \
#     .

# if echo $PLATFORM | grep "amd64" > /dev/null; then
#     docker buildx build \
#         ${LOAD_OR_PUSH} \
#         --platform=linux/amd64 \
#         ${OLLAMA_COMMON_BUILD_ARGS} \
#         --target runtime-rocm \
#         -f Dockerfile \
#         -t ${FINAL_IMAGE_REPO}:$VERSION-rocm \
#         .
# fi

#!/bin/sh

set -eu

. "$(dirname "$0")/env.sh"

PUSH=${PUSH:-""}

if [ -z "${PUSH}" ]; then
    echo "Building ${FINAL_IMAGE_REPO}:$VERSION locally.  set PUSH=1 to push"
    # With Podman, you can load an image locally by just building it (no `--load`).
    LOAD_OR_PUSH=""
else
    echo "Will be pushing ${FINAL_IMAGE_REPO}:$VERSION"
    LOAD_OR_PUSH="--push"
fi

# Replace "docker buildx build" with "podman build"
podman buildx build \
    --platform=linux/amd64 \
    ${OLLAMA_COMMON_BUILD_ARGS} \
    -f Dockerfile \
    -t "${FINAL_IMAGE_REPO}:$VERSION" \
    .

# If your platform includes amd64
if echo "$PLATFORM" | grep "amd64" >/dev/null; then
    # Build the AMD64/ROCm variant
    podman buildx build \
        --platform=linux/amd64

    ${OLLAMA_COMMON_BUILD_ARGS} \
        --target runtime-rocm \
        -f Dockerfile \
        -t "${FINAL_IMAGE_REPO}:$VERSION-rocm" \
        .
fi

# If you need to push after building:
if [ -n "${PUSH}" ]; then
    podman push "${FINAL_IMAGE_REPO}:$VERSION"
    podman push "${FINAL_IMAGE_REPO}:$VERSION-rocm"
fi
