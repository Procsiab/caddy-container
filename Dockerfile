FROM alpine:3.10
LABEL maintainer "Lorenzo Prosseda <lerokamut@gmail.com>"

# Configuration parameters
ARG collect_metrics=off
ARG license_type=personal
ARG linux_architecture=amd64

# Download environment tools
RUN apk add --no-cache \
    ca-certificates \
    wget \
    tar

# Download Caddy from its website
RUN cd /tmp && \
    wget https://caddyserver.com/download/linux/${linux_architecture}\?plugins\=http.forwardproxy,http.ipfilter,http.minify,http.nobots,http.proxyprotocol,http.ratelimit,http.realip,http.restic,tls.dns.cloudflare\&license\=${license_type}\&telemetry\=${collect_metrics} -O caddy.tar.gz && \
    tar -zxf caddy.tar.gz caddy && \
    mv /tmp/caddy /usr/bin/caddy

# Validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

# Configure system
EXPOSE 80 443
VOLUME /root/.caddy /srv
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile

# Run the proxy
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=true"]
