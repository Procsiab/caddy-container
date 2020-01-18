# Caddy Container

## How it works

This repository will help you create and deploy a container with the caddy proxy, 
even among different Docker hosts. It will use the official caddy website download, 
with some extra plugins.

### Build the image (optional)

You can tweak the image build to fit your needing or, more important, your Docker 
host's architecture; use the following command to run a build using the default 
parameters:

```bash
docker build -t mycustom/caddy .
```

You can change the following options
- `collect_metrics` (on | off)
- `license_type` (personal | enterprise)
- `linux_architecture` (arm7 | amd64 | ...)
- `alpine_image_version` (latest | 3.10 | ...)

To do this, you should append the `--build-arg <option_name>=<value>` flag to the 
build command, for each argument you want to specify a value for.

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

Now you can create other containers and attach them to `caddy_bacbone` to let 
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
services; you should run it on all the workers that joinde your Caddy leader's 
network:

```bash
# Spawn the Swarm network on this node using an independent container
docker run -d --name overlay_net_pinner --net=caddy_backbone --ip=10.0.0.200 nginx
```

### Deploying the container with compose

Using the `docker-compose up -d` command, you will start the Caddy container using 
the Caddyfile located in the repository's directory; whenever you change that file, 
the container will need a restart to let the changes take effect: in that case 
you can use the `docker-compose restart` command.

The Caddyfile and the secrets in the secrets.env file are built to allow a user 
to quickly set up his Cloudflare DNS routing with the Caddy proxy container.

----

**WARNING**

The default docker-compose.yml file will pull the `arm32` variant of the image: 
check the Docker Hub for the desired variant, or build it yourself for your 
target architecture and change the `image` statement in the compose file.
