# Sonarr v4 Custom Build

Custom Docker image build for **Sonarr v4** based on [LinuxServer.io Sonarr](https://github.com/linuxserver/docker-sonarr) with enhancements for CIS / tracker cumulative multi-episode releases and Transmission integration.

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
  sonarr:
    image: ghcr.io/<YOUR_GITHUB_USERNAME>/sonarr-patches:latest
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - ./config:/config
      - /data/media/tv:/tv
      - /data/downloads:/downloads
    ports:
      - 8989:8989
    restart: unless-stopped
```

---

## 🛠 Project Structure

```text
├── .github/
│   └── workflows/
│       └── build-and-push.yml   # CI/CD: Multi-arch (amd64/arm64) build & push to GHCR
├── patches/
│   └── multi-episode-pack.patch # DecisionEngine & Transmission selective download patch (v4)
├── Dockerfile                   # Multi-stage build (.NET 6 SDK -> LinuxServer runtime)
├── docker-compose.example.yml   # Example compose configuration
├── .gitignore
└── README.md
```

---

## ⚙️ GitHub Actions CI/CD

- **Automated Builds**: Every push to the `main` branch triggers a multi-platform build (`linux/amd64`, `linux/arm64`) and publishes to GitHub Container Registry (`ghcr.io/<USERNAME>/<REPO>:latest`).
- **Workflow Dispatch**: Manually trigger builds from the **Actions** tab with custom upstream tags (e.g. `v4.0.19.2979`) or base images.
- **Weekly Schedule**: Automatically rebuilds weekly to incorporate the latest upstream updates and base image security patches.

---

## 💻 Local Build

Build locally with Docker:
```bash
docker build --platform linux/amd64 -t sonarr:local .
```
Build for a specific Sonarr tag/branch:
```bash
docker build --platform linux/amd64 --build-arg SONARR_VERSION=v4.0.19.2979 -t sonarr:local .
```
