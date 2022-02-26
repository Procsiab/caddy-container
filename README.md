# Caddy Container

[![Container Build](https://github.com/Procsiab/caddy-container/actions/workflows/build-container-publish-dockerhub.yaml/badge.svg)](https://github.com/Procsiab/caddy-container/actions/workflows/build-container-publish-dockerhub.yaml)

![Docker Image Version (latest by date)](https://img.shields.io/docker/v/procsiab/caddy?label=Latest%20tag%20pushed%20on%20Docker%20Hub)

## How it works

This repository will help you create and deploy a container with the caddy proxy, 
with the CloudFlare DNS plugin compiled.
Also, the container images for ARMv7, AARCH64 and x86\_64 platforms are automatically 
built from this repository, and available from [Docker Hub](https://hub.docker.com/r/procsiab/caddy)

#### Changing the configuration

To change the contents of *Caddyfile* and *secrets.env* without having Git to
store your secrets, run the following git commands:

```bash
git update-index --assume-unchanged Caddyfile
git update-index --assume-unchanged secrets.env
```

### Build the image (optional)

The Containerfile is written to allow cross-architecture builds, using QEMU's user-static package: to build the image on x86 for another platform do the following:

- be sure to install `qemu-user-static` if you need to run the container on an architecture different from the local one;
- to build the container for *aarch64*, run `cp $(which qemu-aarch64-static) .`;
- run the build process with `podman build -f Containerfile.aarch64 -t mycompany/caddy:latest-aarch64 .`.

To build using a different Caddy version (e.g. 2.0.0), append the following argument on the command line to `podman build`:
```bash
--build-arg=caddyversion=2.0.0
```

----

**NOTE**: *If you have built the image and want to use it  with compose, you will need to change 
the `image:` statement into the podman-compose.yml file*
