FROM samanhappy/mcphub:latest

# Install runtime dependencies needed for AWS operations and Docker-in-Docker tooling.
# Running as root to install system packages; no non-root user is set afterwards.
USER root
RUN apt-get update && apt-get install -y \
    docker.io \
    gcc \
    python3-pip \
    awscli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY config/mcp_settings.json /app/mcp_settings.json

EXPOSE 3000
CMD ["node", "dist/index.js"]
