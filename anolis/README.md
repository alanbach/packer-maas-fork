# Anolis OS Packer Template for MAAS

## Introduction

The Packer template in this directory creates a Anolis OS AMD64/ARM64 image for use with MAAS.

## Prerequisites (to create the image)

* A machine running Ubuntu 22.04+ with the ability to run KVM virtual machines.
* qemu-utils, libnbd-bin, nbdkit and fuse2fs
* [Packer](https://www.packer.io/intro/getting-started/install.html), v1.8.0 or newer
* The [Anolis OS ISO images](https://openanolis.cn/download?lang=en)

## Requirements (to deploy the image)

* [MAAS](https://maas.io) 3.3+
* [Curtin](https://launchpad.net/curtin) 22.1+

## Customizing the Image

The deployment image may be customized by modifying http/anolis.ks.pkrtpl.hcl. See the [pykickstart documentation](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html) for more information.

## Building an image

You can easily build the image using the Makefile (boot or full ISO):

```shell
make ISO=/PATH/TO/AnolisOS-23.5-x86_64-boot.iso
```

Note: anolis.pkr.hcl is configured to run Packer in headless mode. Only Packer
output will be seen. If you wish to see the installation output connect to the
VNC port given in the Packer output or change the value of headless to false in
anolis.pkr.hcl.

Installation is non-interactive.

### Makefile Parameters

#### ARCH

Defaults to x86_64 to build AMD64 compatible images. In order to build ARM64 images, use ARCH=aarch64

#### ISO

The path to the installation ISO image for Anolis OS.

#### TIMEOUT

The timeout to apply when building the image. The default value is set to 1h.

#### VERSION

Anolis OS version. Default is currently set to 23.

## Uploading an image to MAAS

```shell
maas $PROFILE boot-resources create \
    name='custom/anolis' title='Anolis OS Custom' \
    architecture='amd64/generic' filetype='tgz' \
    base_image='rhel/10' content@=anolis.tar.gz
```

For ARM64, use:

```shell
maas $PROFILE boot-resources create \
    name='custom/anolis' title='Anolis OS Custom' \
    architecture='arm64/generic' filetype='tgz' \
    base_image='rhel/10' content@=anolis.tar.gz
```

## Default Username

The default username is ```admin```
