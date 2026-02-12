terraform {
  required_version = ">= 1.5"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.36.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.19.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.12.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "kubernetes" {
  config_path = var.kube_config
}

provider "helm" {
  kubernetes = {
    config_path = var.kube_config
  }
}

provider "minio" {
  minio_server   = local.s3_host
  minio_user     = var.hcloud_s3_access_key
  minio_password = var.hcloud_s3_secret_key
  minio_region   = local.region
  minio_ssl      = true
}
