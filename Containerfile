ARG BASE_VERSION=15
FROM ghcr.io/daemonless/base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG UPSTREAM_URL="https://plex.tv/api/downloads/5.json"
ARG UPSTREAM_JQ=".computer.FreeBSD.version"
ARG HEALTHCHECK_ENDPOINT="http://localhost:32400/identity"

ENV HEALTHCHECK_URL="${HEALTHCHECK_ENDPOINT}"

LABEL org.opencontainers.image.title="Plex Media Server" \
    org.opencontainers.image.description="Plex Media Server on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/plex" \
    org.opencontainers.image.url="https://plex.tv/" \
    org.opencontainers.image.documentation="https://support.plex.tv/" \
    org.opencontainers.image.licenses="Proprietary" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="32400" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.category="Media Servers" \
    io.daemonless.upstream-url="${UPSTREAM_URL}" \
    io.daemonless.upstream-jq="${UPSTREAM_JQ}" \
    io.daemonless.healthcheck-url="${HEALTHCHECK_ENDPOINT}"

# VERSION options:
#   container - use baked version, no updates (default)
#   public    - update to latest public channel
#   latest    - alias for plexpass
#   plexpass  - update to plexpass channel (requires PlexOnlineToken)
#   x.y.z     - update to specific version
ENV VERSION="container"

# Create directories
RUN mkdir -p /config /transcode /data /app /usr/local/share/plexmediaserver && \
    chown -R bsd:bsd /config /transcode /data /app /usr/local/share/plexmediaserver

# Download Plex at build time (public channel)
RUN PLEX_URL="https://plex.tv/downloads/latest/1?channel=16&build=freebsd-x86_64&distro=freebsd" && \
    echo "Downloading Plex from: ${PLEX_URL}" && \
    fetch -qo /tmp/plex.tar.bz2 "${PLEX_URL}" && \
    tar -xf /tmp/plex.tar.bz2 -C /usr/local/share/plexmediaserver --strip-components=1 && \
    rm /tmp/plex.tar.bz2 && \
    "/usr/local/share/plexmediaserver/Plex Media Server" --version | tr -d 'v' > /app/version && \
    chown -R bsd:bsd /usr/local/share/plexmediaserver /app

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/plex/run /etc/services.d/plex/finish /etc/cont-init.d/* 2>/dev/null || true

# Plex ports (matching official pms-docker)
EXPOSE 32400/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp

# Volumes matching official pms-docker
VOLUME /config /transcode /data
