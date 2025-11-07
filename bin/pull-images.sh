#!/bin/bash
set -e

echo "# Pull images"
echo "--------------------"

if [ $# -eq 0 ]; then
    echo "No images provided."
    echo "Usage: $0 <image1> <image2> ..."
    exit 1
fi

for image in "$@"; do
    echo "Pulling $image..."
    docker pull "$image"
done

echo "All images pulled."