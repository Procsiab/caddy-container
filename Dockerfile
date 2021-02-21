FROM amd64/alpine:3.13.2
LABEL maintainer "Lorenzo Prosseda <lerokamut@gmail.com>"

# Configuration parameters
ARG platform=linux
ARG architecture=amd64

# Download environment tools
RUN apk add --no-cache \
    ca-certificates \
    wget \
    tar

# Create directories and download Caddy from its website
RUN mkdir -p \
    /config/caddy \
    /data/caddy \
    /etc/caddy \
    /usr/share/caddy && \
    cd /tmp && \
    wget "https://caddyserver.com/api/download?os=${platform}&arch=${architecture}&p=github.com%2Fcaddy-dns%2Fcloudflare" -q -O caddy && \
    chmod +x /tmp/caddy && \
    mv /tmp/caddy /usr/bin/caddy

# Configure system
EXPOSE 80 443
VOLUME /config /data
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data
WORKDIR /srv

COPY Caddyfile /etc/caddy/Caddyfile

# Run the proxy
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "-config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
