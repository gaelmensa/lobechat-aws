FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    sudo \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl — fetches "stable" version dynamically; no version pin or checksum
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Install eksctl — latest release, no checksum verification
RUN curl --silent --location \
    "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" \
    | tar xz -C /tmp \
    && mv /tmp/eksctl /usr/local/bin/

# Install zellij — latest release, no version pin or checksum
RUN curl -L \
    "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz" \
    | tar xz -C /usr/local/bin/

# Create sandbox user with passwordless sudo — broad privilege escalation
RUN useradd -m -s /bin/bash sandbox \
    && echo "sandbox ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER sandbox
WORKDIR /home/sandbox
CMD ["/bin/bash"]
