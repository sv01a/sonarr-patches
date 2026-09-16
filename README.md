# Sonarr Custom Build (Cumulative Multi-Episode Releases & Transmission Selective Download)

Автоматическая сборка кастомного образа Sonarr v4 на базе [LinuxServer.io Sonarr](https://github.com/linuxserver/docker-sonarr) с поддержкой:
1. **Накопительных многосерийных раздач (S01E01-05, E1-4 и др.)**: Sonarr одобряет релиз пака, если в нём есть хотя бы одна отсутствующая (Missing) или требующая апгрейда серия.
2. **Выборочного скачивания в Transmission**: при отправке пака серий в Transmission скачиваются **только** недостающие эпизоды (остальным файлам ставится `wanted = false` / `files-unwanted`), предотвращая повторную загрузку уже имеющихся серий.

---

## 🚀 Использование Docker-образа

### Docker Compose
```yaml
services:
  sonarr:
    image: ghcr.io/<YOUR_GITHUB_USERNAME>/<REPO_NAME>:latest
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
    volumes:
      - ./config:/config
      - /data/media/tv:/tv
      - /data/downloads:/downloads
    ports:
      - 8989:8989
    restart: unless-stopped
```

---

## 🛠 Архитектура репозитория

```
├── .github/
│   └── workflows/
│       └── build-and-push.yml   # CI/CD: автосборка для amd64/arm64 и публикация в GHCR
├── patches/
│   └── multi-episode-pack.patch # Патч с логикой DecisionEngine и Transmission selective download
├── Dockerfile                   # Multi-stage сборка .NET SDK -> LinuxServer runtime
├── docker-compose.example.yml
└── README.md
```

---

## ⚙️ Как работает GitHub Actions

1. При пуше в ветку `main` запускается сборка Docker-образа для двух архитектур: `linux/amd64` и `linux/arm64`.
2. Готовый образ автоматически пушится в ваш GitHub Container Registry (`ghcr.io/<YOUR_GITHUB_USERNAME>/<REPO_NAME>:latest`).
3. Вкладка **Actions** -> **Workflow Dispatch** позволяет вручную запустить сборку под конкретный тег/ветку upstream Sonarr (например, `v4.0.19.2979`).
4. По расписанию (раз в неделю) образ пересобирается, подтягивая актуальные обновления базового образа.

---

## 💻 Локальная сборка

Собрать локально для архитектуры amd64:
```bash
docker build --platform linux/amd64 -t sonarr:local .
```
Собрать для конкретной версии:
```bash
docker build --platform linux/amd64 --build-arg SONARR_VERSION=main -t sonarr:local .
```
