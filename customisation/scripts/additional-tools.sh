#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# https://github.com/mikefarah/yq
YQ_VERSION=v4.49.2
YQ_BINARY=yq_linux_${ARCH}
echo "Installing yq $YQ_VERSION..."
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq
