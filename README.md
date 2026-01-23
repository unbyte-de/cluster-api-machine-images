
<p align="center">
  <a href="https://unbyte.de">
    <img src="https://www.unbyte.de/wp-content/uploads/2024/12/unbyte_logo.svg" alt="unbyte GmbH" width="300">
  </a>
</p>

# Cluster API Machine Images

[![Packer](https://img.shields.io/badge/Packer-02A8EF?logo=packer&logoColor=white)](https://www.packer.io/)
[![Hetzner Cloud](https://img.shields.io/badge/Hetzner%20Cloud-D50C2D?logo=hetzner&logoColor=white)](https://www.hetzner.com/cloud)
<!-- [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE) -->
<!-- [![GitHub Actions](https://img.shields.io/github/actions/workflow/status/unbyte/cluster-api-machine-images/hcloud-image-builder.yaml?label=image%20builder)](https://github.com/unbyte-de/cluster-api-machine-images/actions/workflows/hcloud-image-builder.yaml) -->
<!-- [![Pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit) -->
<!-- [![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/) -->
<!-- [![Kubernetes](https://img.shields.io/badge/Kubernetes-1.31-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io) -->
<!-- [![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md) -->

This repository contains configuration to build custom Hetzner Cloud images using the [kubernetes-sigs/image-builder](https://github.com/kubernetes-sigs/image-builder).
The primary goal is to create images compatible with Cluster API (CAPI) for node provisioning.

At the moment we create a machine image only for HCloud based on Ubuntu 24.04 with Kubernetes version 1.31.4.

## Configuration

We mostly use the defaults from [image-builder](https://image-builder.sigs.k8s.io/capi/capi#configuration).
In [config](config/) folder we have our configuration.

We defined a [packer-patch.json](./config/packer-patch.json) file,
which we use to patch the original [packer.json](https://github.com/kubernetes-sigs/image-builder/blob/main/images/capi/packer/hcloud/packer.json) file,
so that packer runs our scripts.

We also had to define [hcloud-config.json](./config/hcloud-config.json) file to fix hcloud server type.

### Variables

We define which versions of k8s, CNI and containerd to install in [config/vars/k8s-1.31.json](config/vars/k8s-1.31.json).

### Additional Tools

We implement a script, which installs additional tools in machine images,
in [config/scripts/additional-tools.sh](./config/scripts/additional-tools.sh).

## Image Generation

### Actions

We have a [workflow](https://github.com/unbyte-de/cluster-api-machine-images/actions/workflows/hcloud-image-builder.yaml) to generate an image,
which has to be executed manually.
You just have to click on "Run workflow" and select the hetzner project and base OS.

#### New Project

When you have a new Hetzner project and want to generate an image for it, you have to

1. Generate a API token for that project
2. [Create a new environment](https://github.com/unbyte-de/cluster-api-machine-images/settings/environments/new) with the same name as the project
3. Define environment secrets `HCLOUD_TOKEN`, `CONTAINER_REGISTRY_URL`, `CONTAINER_REGISTRY_USERNAME` and `CONTAINER_REGISTRY_PASSWORD` in the new environment

### Local

Here is commands to run locally which builds an image and pushes it into HCloud.
Image will be pushed to `Snapshots` of the project where generated API token belongs to.

We use the [official container image](https://image-builder.sigs.k8s.io/capi/container-image) to generate an image locally.

Variables:

* `HCLOUD_TOKEN`: Generate an hcloud API token at `https://console.hetzner.com/projects/<your-project-id>/security/tokens`.
* `HCLOUD_LOCATION`: This is the location where packer image builder server provisioned at.
* `OS_INFO`: Operating system to install.
  Possible operating systems are listed in [image-builder documentation](https://image-builder.sigs.k8s.io/capi/providers/hcloud#configuration).
* `PACKER_VAR_FILES`: Where to mount [custom packer var file](./config/vars/k8s-1.31.json).
* `CONTAINER_REGISTRY_URL`: Harbor registry URL for container image proxy.
* `CONTAINER_REGISTRY_USERNAME`
* `CONTAINER_REGISTRY_PASSWORD`

```sh
export HCLOUD_TOKEN="generate-it"
export HCLOUD_LOCATION=fsn1
export OS_INFO="ubuntu-2404"
export PACKER_VAR_FILES=/tmp/k8s-1.31.json
export CONTAINER_REGISTRY_URL="https://registry.mgt.unbyte.de"
export CONTAINER_REGISTRY_USERNAME="get-username"
export CONTAINER_REGISTRY_PASSWORD="get-password"
export IMAGE_BUILDER=registry.k8s.io/scl-image-builder/cluster-node-image-builder-amd64:v0.1.48@sha256:4a522321b30c855efeeb6503f663046aca5c12f14edeb41ee7ef3ae617e3597a

docker run --rm \
  --env HCLOUD_LOCATION=${HCLOUD_LOCATION} \
  --env HCLOUD_TOKEN=${HCLOUD_TOKEN} \
  --env PACKER_VAR_FILES=${PACKER_VAR_FILES} \
  --env OS_INFO=${OS_INFO} \
  -v "${PWD}/config/scripts:/home/imagebuilder/packer/hcloud/scripts" \
  -v "${PWD}/config/hcloud-config.json:/home/imagebuilder/packer/hcloud/hcloud-config.json" \
  -v "${PWD}/config/packer-patch.json:/tmp/packer-patch.json" \
  -v "${PWD}/config/vars/k8s-1.31.json:${PACKER_VAR_FILES}" \
  --entrypoint /bin/sh \
  "${IMAGE_BUILDER}" \
  -c 'set -e
      echo "Patch..." &&
      jq --slurpfile patch /tmp/packer-patch.json \
        ".provisioners += \$patch[0].provisioners" \
        packer/hcloud/packer.json > /tmp/packer.json && \
      mv /tmp/packer.json packer/hcloud/packer.json && \
      export PACKER_FLAGS="-var container_registry_url='"${CONTAINER_REGISTRY_URL}"' -var container_registry_username='"${CONTAINER_REGISTRY_USERNAME}"' -var container_registry_password='"${CONTAINER_REGISTRY_PASSWORD}"'" && \
      echo "Validate..." && /usr/bin/make "validate-hcloud-${OS_INFO}" && \
      echo "Build..." && /usr/bin/make "build-hcloud-${OS_INFO}"'
# This will run following command
# /home/imagebuilder/.local/bin/packer build \
#   -var-file="/home/imagebuilder/packer/config/kubernetes.json" \
#   -var-file="/home/imagebuilder/packer/config/cni.json" \
#   -var-file="/home/imagebuilder/packer/config/containerd.json" \
#   -var-file="/home/imagebuilder/packer/config/wasm-shims.json" \
#   -var-file="/home/imagebuilder/packer/config/ansible-args.json" \
#   -var-file="/home/imagebuilder/packer/config/goss-args.json" \
#   -var-file="/home/imagebuilder/packer/config/common.json" \
#   -var-file="/home/imagebuilder/packer/config/additional_components.json" \
#   -var-file="/home/imagebuilder/packer/config/ecr_credential_provider.json" \
#   -var container_registry_url=https://registry.mgt.unbyte.de \
#   -color=true \
#   -var-file="packer/hcloud/hcloud-config.json" \
#   -var-file="/home/imagebuilder/packer/hcloud/ubuntu-2404.json" \
#   -var-file="/tmp/k8s-1.31.json" \
#   packer/hcloud/packer.json

```

## References

* <https://github.com/kubernetes-sigs/image-builder/tree/main/images/capi>
  * <https://github.com/kubernetes-sigs/image-builder/tree/main/images/capi/packer/config>
  * <https://github.com/kubernetes-sigs/image-builder/tree/main/images/capi/packer/hcloud>
* <https://image-builder.sigs.k8s.io/capi/providers/hcloud>
* <https://image-builder.sigs.k8s.io/capi/capi#customization>
