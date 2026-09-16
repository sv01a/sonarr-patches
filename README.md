# Sonarr v5 (Develop) Custom Build (Cumulative Multi-Episode Releases & Transmission Selective Download)

Ветка **`v5`** репозитория для сборки разрабатываемой версии **Sonarr v5 (`v5-develop`)** с поддержкой:
1. **Накопительных многосерийных раздач (S01E01-05, E1-4 и др.)**: Sonarr одобряет релиз пака, если в нём есть хотя бы одна отсутствующая (Missing) или требующая апгрейда серия.
2. **Выборочного скачивания в Transmission**: при отправке пака серий в Transmission скачиваются **только** недостающие эпизоды (остальным файлам ставится `wanted = false` / `files-unwanted`), предотвращая повторную загрузку уже имеющихся серий.

---

## 🚀 Использование Docker-образа Sonarr v5

### Docker Compose
```yaml
services:
  sonarr-v5:
    image: ghcr.io/<YOUR_GITHUB_USERNAME>/<REPO_NAME>:v5
    container_name: sonarr-v5
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
    volumes:
      - ./config-v5:/config
      - /data/media/tv:/tv
      - /data/downloads:/downloads
    ports:
      - 8989:8989
    restart: unless-stopped
```

---

## 🛠 Особенности версии v5

- Собирается на базе **.NET 10 SDK** из ветки `v5-develop` официального репозитория Sonarr.
- В качестве базового рантайм-образа используется `lscr.io/linuxserver/sonarr:develop`.
- Патч адаптирован под новую кодовую базу v5 (включая обновленный `UpgradeDiskSpecification` и `MonitoredEpisodeSpecification`).

---

## 💻 Локальная сборка

Собрать локально для архитектуры amd64:
```bash
docker build --platform linux/amd64 -t sonarr:v5-local .
```
