# Multi-step approach handled by GitHub Actions: we build the Roc binary first
# and then use this runtime-only image to run it.

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libtinfo6 \
        sqlite3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# The CI builds the binary as ./web before docker build.
COPY web /usr/local/bin/web
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Default database path (can be overridden at runtime)
ENV DB_PATH=/data/todos.db

EXPOSE 8000
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
