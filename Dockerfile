FROM amd64/alpine:3.11
LABEL maintainer "Lorenzo Prosseda <lerokamut@gmail.com>"

# Configuration parameters
ARG collect_metrics=off
ARG license_type=personal
ARG platform=linux
ARG architecture=amd64
ARG plugin_list="http.forwardproxy,http.ipfilter,http.minify,http.nobots,http.proxyprotocol,http.ratelimit,http.realip,http.restic,tls.dns.cloudflare"

# Download environment tools
RUN apk add --no-cache \
    ca-certificates \
    wget \
    tar

# Download Caddy from its website
RUN cd /tmp && \
    wget https://caddyserver.com/download/${platform}/${architecture}\?plugins\=${plugin_list}\&license\=${license_type}\&telemetry\=${collect_metrics} -q -O caddy.tar.gz && \
    tar -zxf caddy.tar.gz caddy && \
    mv /tmp/caddy /usr/bin/caddy

# Configure system
EXPOSE 80 443
VOLUME /root/.caddy /srv
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile

# Run the proxy
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=true"]
