#!/bin/bash
set -euo pipefail

echo "Validating installed tools..."
yq --version || exit 1

echo "Validating containerd config..."
test -f /etc/containerd/certs.d/docker.io/hosts.toml || exit 1
test -f /etc/containerd/certs.d/gcr.io/hosts.toml || exit 1
test -f /etc/containerd/certs.d/ghcr.io/hosts.toml || exit 1
test -f /etc/containerd/certs.d/quay.io/hosts.toml || exit 1
test -f /etc/containerd/certs.d/registry.k8s.io/hosts.toml || exit 1
test -f /etc/containerd/certs.d/registry.gitlab.com/hosts.toml || exit 1

echo "Validation passed!"
