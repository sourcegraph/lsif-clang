#! /bin/bash

# Build lsif-clang in a container then extra out all the needed files.

set -euo pipefail

# Configuration
image_name="lsif-clang-$USER"
container_name="tmp-lsif-clang-build"

# Learn about our environment
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$script_dir/../../.."
git_commit="$(git rev-parse HEAD)"

output_filename="lsif-clang-aurora-${git_commit}"
output_folder="${root_dir}/${output_filename}"
archive_name="${output_filename}.tar.gz"

# Cleanup our container after usage
dockercleanup() {
    docker rm -f "$container_name" &> /dev/null || true
}

trap dockercleanup EXIT ERR INT TERM
dockercleanup

# Build
cd "$root_dir"
echo "[Building image: $image_name]"
docker build -f ubuntu_1804.Dockerfile -t "$image_name" .

# Start a container with the image
echo "[Starting temporary container: $container_name]"
docker create --name "$container_name" "$image_name"

# Get the files we need out of the image
echo "[Extracting needed files]"
rm -rf "$output_folder"
mkdir -p "$(dirname "$output_folder")"

docker cp "$container_name:/usr/local/bin" "$output_folder"

# Install the shim in our package
mv "$output_folder/lsif-clang" "$output_folder/lsif-clang.bin"
cp "$script_dir/lsif_clang_shim.sh" "$output_folder/lsif-clang"

chown "$USER:$(id -g)" "$output_folder"/*

# Now create our tarball
tar zcf "${archive_name}" "$output_filename"
echo "Created: ${archive_name}"