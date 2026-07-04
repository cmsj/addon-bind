# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

ARG TEMPIO_VERSION=2021.09.0
ARG TARGETARCH

RUN \
    if [ -z "${TARGETARCH}" ]; then \
        echo "TARGETARCH is not set, please use Docker BuildKit for the build." && exit 1; \
    fi \
    && case "${TARGETARCH}" in \
        amd64) tempio_arch="amd64" ;; \
        arm64) tempio_arch="aarch64" ;; \
        *) echo "Unsupported TARGETARCH: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && curl -sSLf -o /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${tempio_arch}"

    apk add --no-cache bind bind-plugins

# Copy root filesystem
COPY rootfs /

LABEL \
      org.opencontainers.image.title: "Home Assistant Add-on: ISC Bind"
      org.opencontainers.image.description: "Bind DNS server"
      org.opencontainers.image.source: "https://github.com/cmsj/addon-bind"
      org.opencontainers.image.licenses: "Apache License 2.0"