.PHONY: all clean build container deploy service secrets

all : clean build secret service deploy

build : 
	buildah bud -t procsiab/caddy:amd64 -f Dockerfile .

container : 
	podman run -d \
		-p 80:80/tcp \
		-p 443:443/tcp \
		-v ./config/:/root/.caddy:Z \
		-v ./Caddyfile/:/etc/Caddyfile:ro \
		--env-file ./secrets.env \
		--env ENABLE_TELEMETRY=false \
		--restart on-failure:3 \
		--hostname caddy

deploy :
	kubectl apply -f ./caddy-deploy.yaml

service :
	kubectl apply -f ./caddy-svc.yaml

secret :
	kubectl apply -f ./cloudflare-credentials.yaml

clean :
	(podman image rm procsiab/caddy:amd64 || echo "Container Image was not present")  && \
	(kubectl delete -f ./caddy-deploy.yaml || echo "Deployment not present") && \
	(kubectl delete -f ./caddy-svc.yaml || echo "Service not present") && \
	(kubectl delete -f ./cloudflare-credentials.yaml || echo "Secret not present")
