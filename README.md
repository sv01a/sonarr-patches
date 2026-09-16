# Sonarr v5 (Develop) Custom Build

Custom Docker image build for **Sonarr v5 (`v5-develop`)** based on [LinuxServer.io Sonarr (develop)](https://github.com/linuxserver/docker-sonarr) with enhancements for CIS / tracker cumulative multi-episode releases and Transmission integration.

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
    image: ghcr.io/<YOUR_GITHUB_USERNAME>/<REPO_NAME>:v5
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

## 🛠 Project Structure

```text
├── .github/
│   └── workflows/
│       └── build-and-push.yml   # CI/CD: Multi-arch (amd64/arm64) build & push to GHCR
├── patches/
│   └── multi-episode-pack.patch # DecisionEngine & Transmission selective download patch (v5)
├── Dockerfile                   # Multi-stage build (.NET 10 SDK -> LinuxServer runtime)
├── docker-compose.example.yml   # Example compose configuration
├── .gitignore
└── README.md
```

---

## ⚙️ GitHub Actions CI/CD

- **Automated Builds**: Every push to the `v5` branch triggers a multi-platform build (`linux/amd64`, `linux/arm64`) and publishes to GitHub Container Registry (`ghcr.io/<USERNAME>/<REPO>:v5`).
- **Workflow Dispatch**: Manually trigger builds from the **Actions** tab with custom upstream tags or base images.
- **Weekly Schedule**: Automatically rebuilds weekly to incorporate the latest upstream updates and base image security patches.

---

## 💻 Local Build

Build locally with Docker:
```bash
docker build --platform linux/amd64 -t sonarr:v5-local .
```
