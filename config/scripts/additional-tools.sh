#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# https://github.com/mikefarah/yq
YQ_VERSION=v4.49.2
YQ_BINARY=yq_linux_${ARCH}
YQ_CHECKSUM="be2c0ddcf426b6a231648610ec5d1666ae50e9f6473e82f6486f9f4cb6e3e2f7"
echo "Installing yq $YQ_VERSION..."
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq
echo "${YQ_CHECKSUM}  /usr/bin/yq" | sha256sum -c -
