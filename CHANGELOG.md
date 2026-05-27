## v0.5.3 (2026-05-27)

### Feat

- **infra**: auto-create MinIO bucket lobe on boot
- switch to Caddy reverse proxy, add qdrant, move vllm to gpu profile
- **db**: add dbmate migration system with schema and seed support
- **lobechat**: use OpenRouter for embeddings

### Fix

- **infra**: use real email and force Let's Encrypt in Caddyfile
- **infra**: use IMDSv2 for metadata fetch, exclude vllm from compose up
- **infra**: remove awscli from apt install, not available in Ubuntu 24.04
- **infra**: inject secrets via templatefile instead of SSM. SSM GetParameter is blocked in the ESADE sandbox. Secrets are now passed directly through Terraform templatefile() vars into user_data.sh. Removed all aws_ssm_parameter resources from main.tf.

## v0.5.2 (2026-01-27)

### Fix

- **mcp**: mount ~/.aws for dynamic credential refresh

## v0.5.1 (2026-01-27)

### Feat

- **mcp**: add AWS Documentation MCP server

## v0.5.0 (2026-01-27)

### Feat

- **mcp**: add AWS resources operations MCP server with test

## v0.4.3 (2026-01-27)

### Feat

- **agents**: add generic screenshot service agent for lobe-chat-agents

## v0.4.2 (2026-01-27)

## v0.4.1 (2026-01-27)

### Fix

- **playwright**: add output-dir and unrestricted file access

## v0.4.0 (2026-01-27)

### Feat

- add MCP server tests and enhance MCPHub configuration

## v0.3.0 (2026-01-27)

### Feat

- add MCPHub integration with LobeChat hotfix
- add vLLM local GPU inference with Gemma 3 270M model

## v0.2.0 (2026-01-26)

### Refactor

- centralize configuration and switch to OpenRouter

## v0.1.0 (2026-01-26)

### Feat

- initial LobeChat local stack setup
