# syntax=docker/dockerfile:1
ARG SONARR_VERSION=v5-develop
ARG BASE_IMAGE=lscr.io/linuxserver/sonarr:develop

# --- Build Stage (Dynamic .NET SDK installation for Sonarr v5) ---
FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS builder
ARG SONARR_VERSION
ARG TARGETARCH

RUN apt-get update && apt-get install -y git curl ca-certificates jq --no-install-recommends && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch ${SONARR_VERSION} https://github.com/Sonarr/Sonarr.git .

# Install the exact .NET SDK version declared in global.json
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --jsonfile /src/global.json --install-dir /usr/share/dotnet || \
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 10.0 --install-dir /usr/share/dotnet

ENV PATH="/usr/share/dotnet:${PATH}"
ENV DOTNET_ROOT="/usr/share/dotnet"

COPY patches/ /tmp/patches/
RUN for patch in /tmp/patches/*.patch; do \
      if [ -f "$patch" ]; then \
        echo "Applying patch: $patch"; \
        git apply --3way "$patch" || exit 1; \
      fi; \
    done

# Map Docker architecture to .NET RID for Alpine musl
RUN case "${TARGETARCH}" in \
      "amd64") RID="linux-musl-x64" ;; \
      "arm64") RID="linux-musl-arm64" ;; \
      "arm")   RID="linux-musl-arm" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    echo "Publishing Sonarr v5 for runtime: $RID" && \
    dotnet publish src/NzbDrone.Console/Sonarr.Console.csproj \
      -c Release \
      -f net10.0 \
      -r "$RID" \
      --self-contained true \
      -p:PublishTrimmed=false \
      -p:SolutionDir=/src/src/ \
      -o /app/out

# --- Runtime Image ---
FROM ${BASE_IMAGE}

COPY --from=builder /app/out/ /app/sonarr/bin/

# Ensure proper permissions and retain executable flags
RUN chmod -R a+rX /app/sonarr/bin && \
    chmod a+x /app/sonarr/bin/Sonarr /app/sonarr/bin/ffprobe 2>/dev/null || true
