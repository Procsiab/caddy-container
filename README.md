# Caddy Container

[![Container Build](https://github.com/Procsiab/caddy-container/actions/workflows/build-container-publish-dockerhub.yaml/badge.svg)](https://github.com/Procsiab/caddy-container/actions/workflows/build-container-publish-dockerhub.yaml)

![Docker Image Version (latest by date)](https://img.shields.io/docker/v/procsiab/caddy?label=Latest%20tag%20pushed%20on%20Docker%20Hub)

## How it works

This repository will help you create and deploy a container with the caddy proxy, 
even among different Docker hosts. It will use the official caddy website download, 
with some extra plugins by default.  
Also, the Docker Images for ARMv7, AARCH64 and x86\_X64 platforms are automatically 
built from this repository, and available from [Docker Hub](https://hub.docker.com/r/procsiab/caddy)

#### Changing the configuration

To change the contents of *Caddyfile* and *secrets.env* without having Git to
store your secrets, run the following git command:

```bash
git update-index --assume-unchanged Caddyfile
git update-index --assume-unchanged secrets.env
```

### Build the image (optional)

You can tweak the image build to fit your needing or, more important, your Docker 
host's architecture; use the following command to run a build using the default 
parameters:

|Option name|Example value|
|-|:-:|
|`platform` | (linux \| windows \| ...)|
|`architecture` | (arm7 \| amd64 \| ...)|

**NOTE**: The Cloudflare DNS Caddy module is included by default as a strong requirement.

To do this, you should append the `--build-arg <option_name>=<value>` flag to the 
build command, for each argument you want to specify a value for.

The Dockerfile is written to allow cross-architecture builds, using QEMU's user-static package: to build the image on x86 for another platform do the following:

- be sure to install `qemu-user-static` if you need to run the container on an architecture different from the local one;
- to build the container for *aarch64*, run `cp $(which qemu-aarch64-static) .`;
- run the build process with `docker build -f Dockerfile.aarch64 -t myregistry/caddy:latest-aarch64 .`.

----

**NOTE**: *If you have built the image and want to use it, you will need to change 
the `image:` statement into the docker-compose.yml file*

### Create the Docker networks

This container image was intended to work using the Docker container abstraction 
by using a *bridge* network, exposing the HTTP/S host's ports, and an *overlay* 
network, which connects other containers that need proxy forwarding to the Caddy 
container.

The latter network can be created only by joining a Docker Swarm with all the 
Docker hosts that need to talk to the Caddy conainer; ou will need to set up 
the Swarm even if you are not planning to deploy any services

Here are the commands that set up the Swarm on a chosen leader node:

```bash
# Initialize the Docker swarm, using the current node as leader
docker swarm init --advertise-addr=<LEADER_NODE_IP>
# Create the two networks for Caddy container
docker network create caddy_exposed -d bridge
docker network create -d overlay --attachable caddy_backbone
```

Now you can create other containers and attach them to `caddy_backbone` to let 
Caddy talk with them; also, you have the benefit of Docker's internal DNS: you 
are able to write the container's name into the Caddyfile, even if that 
container is on a different Docker host.

On the worker nodes (the non-leader ones), you need to let them join your swarm 
by providing the token returned by the previous `docker swarm init` command. 
You should use it in the following way:

```bash
# Join the Docker Swarm
docker swarm join --token <SWARM_TOKEN> --advertise-addr <WORKER_NODE_IP> <LEADER_NODE_IP>:2377
```

----

**WARNING**

The following command is needed if you will use docker-compose instead deploying 
services; you should run it on using the same number of replicas as the workers that 
joined your Caddy leader's network (the command below must be run on the swarm leader 
with only a single worker in the cluster)

```bash
docker service create --network caddy_backbone --constraint node.role==worker --replicas 1 --name pinner busybox sh -c "while [ 1 -eq 1 ]; do sleep 1; done"
```

### Deploying the container with compose

Using the `docker-compose up -d` command, you will start the Caddy container using 
the Caddyfile located in the repository's directory; whenever you change that file, 
the container will need a restart to let the changes take effect: in that case 
you can use the `docker-compose restart` command.

The Caddyfile and the secrets in the secrets.env file are built to allow a user 
to quickly set up his Cloudflare DNS routing to the Caddy proxy container.

----

**WARNING**

The default docker-compose.yml file will pull the `-aarch64` variant of the
image: check the Docker Hub for the desired variant, or build it yourself for your 
target architecture and change the `image` statement in the compose file.
