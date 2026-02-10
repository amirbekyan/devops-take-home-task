variable "hcloud_token" {
  type        = string
  description = "Hetzner Cloud project authentication token"
}

variable "hcloud_s3_access_key" {
  type        = string
  description = "Hetzner Cloud object storage access key"
}

variable "hcloud_s3_secret_key" {
  type        = string
  description = "Hetzner Cloud object storage secret key"
}

variable "kube_config" {
  type        = string
  description = "Static Kubernetes config file path"
  default     = "./sec/kube.config"
}
