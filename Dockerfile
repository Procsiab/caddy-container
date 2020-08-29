FROM amd64/alpine:3.12.0
LABEL maintainer "Lorenzo Prosseda <lerokamut@gmail.com>"

# Configuration parameters
ARG platform=linux
ARG architecture=amd64

# Download environment tools
RUN apk add --no-cache \
    ca-certificates \
    wget \
    tar

# Download Caddy from its website
RUN cd /tmp && \
    wget "https://caddyserver.com/api/download?os=${platform}&arch=${architecture}&p=github.com%2Fcaddy-dns%2Fcloudflare" -q -O caddy && \
    chmod +x /tmp/caddy && \
    mv /tmp/caddy /usr/bin/caddy

# Configure system
EXPOSE 80 443
VOLUME /root/.caddy /srv
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile

# Run the proxy
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "-config", "/etc/Caddyfile"]
