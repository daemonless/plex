# Plex Media Server

Plex Media Server on FreeBSD. Downloads Plex binary at runtime based on `VERSION` environment variable.

## Quick Start

```bash
podman run -d --name plex \
  -p 32400:32400 \
  -e PUID=1000 -e PGID=1000 \
  -e VERSION=public \
  -v /path/to/config:/config \
  -v /path/to/media:/data \
  ghcr.io/daemonless/plex:latest
```

Access at: http://localhost:32400/web

## podman-compose

```yaml
services:
  plex:
    image: ghcr.io/daemonless/plex:latest
    container_name: plex
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - VERSION=public
      # - PLEX_CLAIM=claim-xxxx  # Optional: from https://plex.tv/claim
      # - ADVERTISE_IP=http://192.168.1.100:32400/
    volumes:
      - /data/config/plex:/config
      - /data/media:/data
      - /tmp/plex-transcode:/transcode
    ports:
      - 32400:32400
      - 8324:8324
      - 32469:32469
      - 1900:1900/udp
      - 32410:32410/udp
      - 32412:32412/udp
      - 32413:32413/udp
      - 32414:32414/udp
    restart: unless-stopped
```

## Tags

| Tag | Description |
|-----|-------------|
| `:latest` | Runtime download, use `VERSION` env var to select channel |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VERSION` | `public` | Plex version/channel (see below) |
| `PLEX_CLAIM` | | Claim token from https://plex.tv/claim |
| `ADVERTISE_IP` | | Override advertised IP address |
| `PUID` | `1000` | User ID for app |
| `PGID` | `1000` | Group ID for app |
| `TZ` | `UTC` | Timezone |

### VERSION Options

| Value | Description |
|-------|-------------|
| `container` | Use installed version, no updates |
| `public` | Public channel (default) |
| `latest` | Alias for `plexpass` |
| `plexpass` | PlexPass channel (requires PlexOnlineToken) |
| `x.y.z` | Specific version number |

**Note:** PlexPass versions require authentication. Log in via the web UI first, then restart the container with `VERSION=plexpass`. The token is read from `Preferences.xml`.

## Volumes

| Path | Description |
|------|-------------|
| `/config` | Configuration and database |
| `/data` | Media library |
| `/transcode` | Temporary transcoding directory |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 32400 | TCP | Web UI and API |
| 8324 | TCP | Companion app |
| 32469 | TCP | DLNA |
| 1900 | UDP | SSDP discovery |
| 32410-32414 | UDP | GDM discovery |

## Logging

This image uses `s6-log` for internal log rotation.
- **System Logs**: `/config/logs/daemonless/plex/`
- **Application Logs**: `/config/Library/Application Support/Plex Media Server/Logs/`
- **Podman Logs**: Output mirrored to console, `podman logs` works

## Notes

- **User:** `bsd` (UID/GID set via PUID/PGID, default 1000)
- **Healthcheck:** `--health-cmd /healthz`
- **Base:** Built on `ghcr.io/daemonless/base` (FreeBSD)
- **Runtime Download:** Plex binary downloaded on first start, not baked into image

## Links

- [Plex Website](https://plex.tv/)
- [Plex Support](https://support.plex.tv/)
