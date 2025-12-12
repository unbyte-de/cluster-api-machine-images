#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

mkdir -p /etc/containerd/certs.d/docker.io
cat >/etc/containerd/certs.d/docker.io/hosts.toml <<EOL
server = "https://docker.io"

[host."http://harbor.devops1.pbm.sh/v2/proxy-docker.io"]
  capabilities = ["pull", "resolve"]
  override_path = true
EOL

mkdir -p /etc/containerd/certs.d/gcr.io
cat >/etc/containerd/certs.d/gcr.io/hosts.toml <<EOL
server = "https://gcr.io"

[host."http://harbor.devops1.pbm.sh/v2/proxy-gcr.io"]
  capabilities = ["pull", "resolve"]
  override_path = true
EOL

mkdir -p /etc/containerd/certs.d/ghcr.io
cat >/etc/containerd/certs.d/ghcr.io/hosts.toml <<EOL
server = "https://ghcr.io"

[host."http://harbor.devops1.pbm.sh/v2/proxy-ghcr.io"]
  capabilities = ["pull", "resolve"]
  override_path = true
EOL

mkdir -p /etc/containerd/certs.d/quay.io
cat >/etc/containerd/certs.d/quay.io/hosts.toml <<EOL
server = "https://quay.io"

[host."http://harbor.devops1.pbm.sh/v2/proxy-quay.io"]
  capabilities = ["pull", "resolve"]
  override_path = true
EOL

mkdir -p /etc/containerd/certs.d/registry.k8s.io
cat >/etc/containerd/certs.d/registry.k8s.io/hosts.toml <<EOL
server = "https://registry.k8s.io"

[host."http://harbor.devops1.pbm.sh/v2/proxy-registry.k8s.io"]
  capabilities = ["pull", "resolve"]
  override_path = true
EOL

mkdir -p /etc/containerd/certs.d/registry.gitlab.com
cat >/etc/containerd/certs.d/registry.gitlab.com/hosts.toml <<EOL
server = "https://registry.gitlab.com"

[host."http://harbor.devops1.pbm.sh/v2/proxy-registry.gitlab.com"]
  capabilities = ["pull", "resolve"]
  override_path = true
EOL
