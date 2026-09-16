# syntax=docker/dockerfile:1
ARG BASE_IMAGE=lscr.io/linuxserver/sonarr:latest
FROM ${BASE_IMAGE}
ARG TARGETARCH

COPY out/${TARGETARCH}/ /app/sonarr/bin/

RUN chmod -R a+rX /app/sonarr/bin && \
    chmod a+x /app/sonarr/bin/Sonarr /app/sonarr/bin/ffprobe 2>/dev/null || true
