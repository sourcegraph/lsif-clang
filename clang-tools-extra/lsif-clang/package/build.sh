#!/usr/bin/env bash

# Build lsif-clang in a container then extract out all the needed files.

set -euo pipefail

# Configuration
IMAGE_NAME="lsif-clang-$USER"
CONTAINER_NAME="tmp-lsif-clang-build"

# Cleanup our container after usage
dockercleanup() {
    docker rm -f "$CONTAINER_NAME" &> /dev/null || true
}

trap dockercleanup EXIT ERR INT TERM
dockercleanup

# Learn about our environment
cd "$(dirname "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(pwd)"
ROOT_DIR="$SCRIPT_DIR/../../.."
GIT_COMMIT_SHA="$(git rev-parse --short HEAD)"

# Build
cd "$ROOT_DIR"
echo "[Building image: $IMAGE_NAME]"
docker build -f Bundled.Dockerfile -t "$IMAGE_NAME" .

# Start a container with the image
echo "[Starting temporary container: $CONTAINER_NAME]"
docker create --name "$CONTAINER_NAME" "$IMAGE_NAME"

OUTPUT_TARBALL_BASENAME="lsif-clang-${GIT_COMMIT_SHA}"
OUTPUT_DIR="${ROOT_DIR}/build/bundled/${OUTPUT_TARBALL_BASENAME}"
TARBALL_PATH="${ROOT_DIR}/build/bundled/${OUTPUT_TARBALL_BASENAME}.tar.gz"

# Get the files we need out of the image
echo "[Extracting needed files]"
rm -rf "$OUTPUT_DIR"
mkdir -p "$(dirname "$OUTPUT_DIR")"

docker cp "$CONTAINER_NAME:/usr/local/bin" "$OUTPUT_DIR"

# Install the shim in our package
mv "$OUTPUT_DIR/lsif-clang" "$OUTPUT_DIR/lsif-clang.bin"
cp "$SCRIPT_DIR/lsif_clang_shim.sh" "$OUTPUT_DIR/lsif-clang"

chown "$USER:$(id -g)" "$OUTPUT_DIR"/*

# Now create our tarball
pushd "$(dirname "$OUTPUT_DIR")"
tar zcf "$(basename "$TARBALL_PATH")" "$(basename "$OUTPUT_DIR")"
popd

OUTPUT_TARBALL_PATH="${OUTPUT_TARBALL_PATH:-}"
if [ ! -z "$OUTPUT_TARBALL_PATH" ]; then
  mv "$TARBALL_PATH" "$OUTPUT_TARBALL_PATH"
  TARBALL_PATH="$OUTPUT_TARBALL_PATH"
fi
echo "Created: $TARBALL_PATH"
