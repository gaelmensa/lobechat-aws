variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type (>= 4 vCPU / 16 GB RAM)"
  type        = string
  default     = "t3.xlarge"
}

variable "ebs_size_gb" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 60
}

variable "admin_cidr" {
  description = "Your IP CIDR allowed for SSH (e.g. 1.2.3.4/32)"
  type        = string
}

variable "repo_url" {
  description = "Git URL of the lobechat-aws fork to clone on the instance"
  type        = string
  default     = "https://github.com/gaelmensa/lobechat-aws.git"
}

# Secrets — stored in SSM SecureString, never in git
variable "key_vaults_secret" {
  description = "LobeChat KEY_VAULTS_SECRET (min 32 chars, base64)"
  type        = string
  sensitive   = true
}

variable "next_auth_secret" {
  description = "NextAuth secret (min 32 chars, base64)"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "minio_root_password" {
  description = "MinIO root password"
  type        = string
  sensitive   = true
}

variable "openrouter_api_key" {
  description = "OpenRouter API key (sk-or-v1-...)"
  type        = string
  sensitive   = true
}
