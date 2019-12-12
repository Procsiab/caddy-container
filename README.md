# Caddy Container

## How it works

This repository will help you create and deploy a Kubernetes Pod with the caddy proxy, 
leveraging Service, Deploy and Secret objects.It will use the official caddy website 
download, with some extra plugins.

### Build the container image

You can tweak the image build to fit your needing or, more important, your Container 
runtime host's architecture; use the following command to run a build using the default 
parameters:

```bash
make build
```

You can change the following options
- `collect_metrics` (on | off)
- `license_type` (personal | enterprise)
- `linux_architecture` (amd64 | armv7 |...)
- `alpine_image_version` (3.10 | latest | ...)

To do this, you should append the `--build-arg <option_name>=<value>` flag to the 
build command, for each argument you want to specify a value for:

```bash
buildah bud -t procsiab/caddy:amd64 -f Dockerfile . --build-arg linux_architecture=armv7
```

----

**NOTE**: *The Kubernetes Deployment automatically uses the locally built container 
image, in stead of pulling it from the docker.io hub*

### Deploying into the cluster

The default Makefile `all` target will set up all the components needed to run 
the pod, route its ports and provide volume mounts and secrets into environment 
variables.

The Caddyfile and the secrets in the secrets.env file are built to allow a user 
to quickly set up his Cloudflare DNS routing with the Caddy proxy container.

To scale the Pod up or down to N instances, use the command:

```bash
kubectl scale --replicas 0 -f caddy-deploy.yaml
```

----

**WARNING**: The default behaviour is to deploy the objects into a single node cluster
