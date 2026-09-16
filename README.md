# Sonarr v5 (Develop) Custom Build

> Sonarr on steroids: cumulative multi-episode pack support, smart selective downloading, and maybe more.

Custom Docker image build for **Sonarr v5 (`v5-develop`)** based on [LinuxServer.io Sonarr (develop)](https://github.com/linuxserver/docker-sonarr).

---

## 🌟 Key Features

1. **Cumulative Multi-Episode Pack Acceptance (S01E01-05, E1-4, etc.)**
   - In standard Sonarr, cumulative releases are rejected if any episode in the pack already exists on disk and meets the cutoff (`Existing file meets cutoff` / `Episode wasn't requested`).
   - This build changes the DecisionEngine validation for multi-episode packs (`subject.Episodes.Count > 1`): the release is **approved** if at least **one** monitored episode in the pack is missing from disk or eligible for quality upgrade.

2. **Transmission Selective Episode Downloading**
   - When a cumulative multi-episode torrent is sent to Transmission, Sonarr inspects torrent files, maps them to episodes, and marks already existing/unmonitored episodes as `wanted = false` (`files-unwanted`).
   - Transmission downloads **only missing episodes**, saving bandwidth and storage.

---

## 🚀 Quick Start (Docker Compose)

```yaml
services:
  sonarr-v5:
    image: ghcr.io/sv01a/sonarr-patches:v5
    container_name: sonarr-v5
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - ./config-v5:/config
      - /data/media/tv:/tv
      - /data/downloads:/downloads
    ports:
      - 8989:8989
    restart: unless-stopped
```

---

## 💻 Local Build

Build locally with Docker:
```bash
docker build --platform linux/amd64 -t sonarr:v5-local .
```
