#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

# ---------------------------------------------------------------------------
# 1. System packages
# ---------------------------------------------------------------------------
apt-get update -y
apt-get install -y ca-certificates curl gnupg jq git

# Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable --now docker
usermod -aG docker ubuntu

# ---------------------------------------------------------------------------
# 2. Derive domains from instance public IP (sslip.io)
# IMDSv2 required: fetch a token first, then use it to get the public IP
# ---------------------------------------------------------------------------
IMDS_TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)
IP_DASHES=$(echo "$PUBLIC_IP" | tr '.' '-')

LOBECHAT_DOMAIN="$IP_DASHES.sslip.io"
CASDOOR_DOMAIN="casdoor.$IP_DASHES.sslip.io"
MINIO_DOMAIN="minio.$IP_DASHES.sslip.io"

echo "LOBECHAT_DOMAIN=$LOBECHAT_DOMAIN"
echo "CASDOOR_DOMAIN=$CASDOOR_DOMAIN"
echo "MINIO_DOMAIN=$MINIO_DOMAIN"

# ---------------------------------------------------------------------------
# 3. Secrets — injected by Terraform templatefile at instance creation
# ---------------------------------------------------------------------------
KEY_VAULTS_SECRET="${key_vaults_secret}"
NEXT_AUTH_SECRET="${next_auth_secret}"
POSTGRES_PASSWORD="${postgres_password}"
MINIO_ROOT_PASSWORD="${minio_root_password}"
OPENROUTER_API_KEY="${openrouter_api_key}"

# ---------------------------------------------------------------------------
# 4. Clone repo
# ---------------------------------------------------------------------------
REPO_DIR=/opt/lobechat
git clone "${repo_url}" "$REPO_DIR"
cd "$REPO_DIR"

# ---------------------------------------------------------------------------
# 5. Write .env
# ---------------------------------------------------------------------------
cat > "$REPO_DIR/.env" <<EOF
LOBECHAT_DOMAIN=$LOBECHAT_DOMAIN
CASDOOR_DOMAIN=$CASDOOR_DOMAIN
MINIO_DOMAIN=$MINIO_DOMAIN

KEY_VAULTS_SECRET=$KEY_VAULTS_SECRET
NEXT_AUTH_SECRET=$NEXT_AUTH_SECRET

AUTH_CASDOOR_ID=a387a4892ee19b1a2249
AUTH_CASDOOR_SECRET=dbf205949d704de81b0b5b3603174e23fbecc354

POSTGRES_PASSWORD=$POSTGRES_PASSWORD

S3_BUCKET=lobe
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD

OPENROUTER_API_KEY=$OPENROUTER_API_KEY

CASDOOR_PORT=47002
POSTGRES_PORT=47003
MINIO_PORT=47005
MINIO_CONSOLE_PORT=47006
QDRANT_PORT=47009
QDRANT_GRPC_PORT=47010
MCPHUB_PORT=47008

AWS_REGION=eu-west-1
AWS_DEFAULT_REGION=eu-west-1
EOF
chmod 600 "$REPO_DIR/.env"

# ---------------------------------------------------------------------------
# 6. Patch casdoor-app.conf — update origin to public Casdoor URL
# ---------------------------------------------------------------------------
sed -i "s|origin = .*|origin = https://$CASDOOR_DOMAIN|" \
  "$REPO_DIR/config/casdoor-app.conf"

# ---------------------------------------------------------------------------
# 7. Patch init_data.json — redirect URI, webhook URL, origin
# ---------------------------------------------------------------------------
jq --arg lobe "https://$LOBECHAT_DOMAIN" \
  '(.applications[] | select(.name == "lobechat") | .redirectUris) = [$lobe + "/api/auth/callback/casdoor"]
   | (.applications[] | select(.name == "lobechat") | .origin) = $lobe
   | (.webhooks[] | select(.name == "webhook_default") | .url) = "http://lobe-chat:3210/api/webhooks/casdoor"' \
  "$REPO_DIR/config/init_data.json" > /tmp/init_data_patched.json
mv /tmp/init_data_patched.json "$REPO_DIR/config/init_data.json"

# ---------------------------------------------------------------------------
# 8. Write Caddyfile with real domains
# ---------------------------------------------------------------------------
cat > "$REPO_DIR/config/Caddyfile" <<EOF
{
  email gaelmensa@gmail.com
  acme_ca https://acme-v02.api.letsencrypt.org/directory
}

$LOBECHAT_DOMAIN {
  reverse_proxy lobe-chat:3210
}

$CASDOOR_DOMAIN {
  reverse_proxy casdoor:8000
}

$MINIO_DOMAIN {
  reverse_proxy minio:9000
}
EOF

# ---------------------------------------------------------------------------
# 9. Start stack (vllm excluded — requires GPU, not available on this instance)
# ---------------------------------------------------------------------------
cd "$REPO_DIR"
docker compose pull caddy casdoor lobe-chat qdrant mcphub minio postgres
docker compose up -d caddy casdoor lobe-chat qdrant mcphub minio postgres

# ---------------------------------------------------------------------------
# 10. Create MinIO bucket
# ---------------------------------------------------------------------------
echo "Waiting for MinIO to be ready..."
until docker exec minio mc alias set local http://localhost:9000 minioadmin "$MINIO_ROOT_PASSWORD" 2>/dev/null; do
  sleep 5
done
docker exec minio mc mb local/lobe --ignore-existing
echo "MinIO bucket 'lobe' created"

echo "=== user-data complete ==="
echo "LobeChat: https://$LOBECHAT_DOMAIN"
echo "Casdoor:  https://$CASDOOR_DOMAIN"
echo "MinIO:    https://$MINIO_DOMAIN"
