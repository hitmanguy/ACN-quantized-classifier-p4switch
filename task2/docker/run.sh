#!/usr/bin/env bash
# Start the P4 dev container with the repo mounted at /work
cd "$(dirname "$0")/../.." || exit 1
sudo docker run --rm -it --privileged -v "$PWD":/work -w /work acn-p4 "${@:-bash}"
sudo chown -R "$(id -u):$(id -g)" task2   # files made by root inside the container
