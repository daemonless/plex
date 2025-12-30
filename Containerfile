ARG BASE_VERSION=15
FROM ghcr.io/daemonless/base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64

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
    io.daemonless.upstream-mode="plex" \
    io.daemonless.upstream-url="https://plex.tv/api/downloads/5.json"

# VERSION options:
#   container - use version in container, no updates
#   public    - public channel (default)
#   latest    - alias for plexpass
#   plexpass  - plexpass channel (requires PlexOnlineToken in Preferences.xml)
#   x.y.z     - specific version number
ENV VERSION="public"

# Create directories
RUN mkdir -p /config /transcode /data /app /usr/local/share/plexmediaserver && \
    chown -R bsd:bsd /config /transcode /data /app /usr/local/share/plexmediaserver

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /healthz /etc/services.d/plex/run /etc/cont-init.d/* 2>/dev/null || true

# Plex ports (matching official pms-docker)
EXPOSE 32400/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp

# Volumes matching official pms-docker
VOLUME /config /transcode /data
