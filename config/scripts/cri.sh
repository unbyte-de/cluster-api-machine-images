#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

: "${CONTAINER_REGISTRY_URL:?CONTAINER_REGISTRY_URL must be set}"
: "${CONTAINER_REGISTRY_PASSWORD:?CONTAINER_REGISTRY_PASSWORD must be set}"
: "${CONTAINER_REGISTRY_USERNAME:?CONTAINER_REGISTRY_USERNAME must be set}"

CONTAINERD_CERTS_DIR="${CONTAINERD_CERTS_DIR:-/etc/containerd/certs.d}"

if [[ ! "$CONTAINER_REGISTRY_URL" =~ ^https:// ]]; then
  echo "Error: CONTAINER_REGISTRY_URL must start with https://"
  exit 1
fi

BASIC_AUTH_B64="$(printf '%s:%s' \
  "$CONTAINER_REGISTRY_USERNAME" \
  "$CONTAINER_REGISTRY_PASSWORD" | base64 | tr -d '\n')"

mkdir -p "${CONTAINERD_CERTS_DIR}/docker.io"
cat >"${CONTAINERD_CERTS_DIR}/docker.io/hosts.toml" <<EOL
server = "https://docker.io"

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-docker.io"]
  capabilities = ["pull", "resolve"]
  override_path = true

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-docker.io".header]
  authorization = "Basic ${BASIC_AUTH_B64}"
EOL

mkdir -p "${CONTAINERD_CERTS_DIR}/gcr.io"
cat >"${CONTAINERD_CERTS_DIR}/gcr.io/hosts.toml" <<EOL
server = "https://gcr.io"

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-gcr.io"]
  capabilities = ["pull", "resolve"]
  override_path = true

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-gcr.io".header]
  authorization = "Basic ${BASIC_AUTH_B64}"
EOL

mkdir -p "${CONTAINERD_CERTS_DIR}/ghcr.io"
cat >"${CONTAINERD_CERTS_DIR}/ghcr.io/hosts.toml" <<EOL
server = "https://ghcr.io"

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-ghcr.io"]
  capabilities = ["pull", "resolve"]
  override_path = true

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-ghcr.io".header]
  authorization = "Basic ${BASIC_AUTH_B64}"
EOL

mkdir -p "${CONTAINERD_CERTS_DIR}/quay.io"
cat >"${CONTAINERD_CERTS_DIR}/quay.io/hosts.toml" <<EOL
server = "https://quay.io"

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-quay.io"]
  capabilities = ["pull", "resolve"]
  override_path = true

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-quay.io".header]
  authorization = "Basic ${BASIC_AUTH_B64}"
EOL

mkdir -p "${CONTAINERD_CERTS_DIR}/registry.k8s.io"
cat >"${CONTAINERD_CERTS_DIR}/registry.k8s.io/hosts.toml" <<EOL
server = "https://registry.k8s.io"

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-registry.k8s.io"]
  capabilities = ["pull", "resolve"]
  override_path = true

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-registry.k8s.io".header]
  authorization = "Basic ${BASIC_AUTH_B64}"
EOL

mkdir -p "${CONTAINERD_CERTS_DIR}/registry.gitlab.com"
cat >"${CONTAINERD_CERTS_DIR}/registry.gitlab.com/hosts.toml" <<EOL
server = "https://registry.gitlab.com"

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-registry.gitlab.com"]
  capabilities = ["pull", "resolve"]
  override_path = true

[host."${CONTAINER_REGISTRY_URL}/v2/proxy-registry.gitlab.com".header]
  authorization = "Basic ${BASIC_AUTH_B64}"
EOL
