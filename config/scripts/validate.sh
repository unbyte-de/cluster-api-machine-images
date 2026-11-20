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

echo "Validating kernel..."
min="6.8.0-149"
# The build VM never reboots, so uname -r still shows the base image's kernel.
# The newest installed /boot/vmlinuz is the one the node boots.
latest=$(ls /boot/vmlinuz-*-generic | sed 's#.*/vmlinuz-##; s#-generic$##' | sort -V | tail -1)
echo "Installed kernel: ${latest}-generic (build VM running $(uname -r))"
if [ "$(printf '%s\n' "$min" "$latest" | sort -V | head -1)" != "$min" ]; then
  echo "ERROR: kernel ${latest} is older than ${min} (CVE-2026-98432)"
  exit 1
fi

echo "Validation passed!"
