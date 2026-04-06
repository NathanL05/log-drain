# ============================================================
# LogDrain — Dockerfile
# Containerises the Bash log generator
# Base: Alpine Linux (lightweight, ~5MB vs ~70MB for Ubuntu)
# ============================================================

FROM alpine:3.19

RUN apk add --no-cache bash

RUN addgroup -S logdrain && adduser -S logdrain -G logdrain

WORKDIR /app

COPY scripts/log-generator.sh ./scripts/log-generator.sh

RUN chmod +x ./scripts/log-generator.sh

RUN mkdir -p /app/logs && chown -R logdrain:logdrain /app

VOLUME ["/app/logs"]


USER logdrain

ENTRYPOINT ["bash", "./scripts/log-generator.sh"]
