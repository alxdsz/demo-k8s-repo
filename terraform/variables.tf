variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "fra1"  # Frankfurt 1
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "demo-cluster"
}

variable "node_size" {
  description = "Size of the worker nodes"
  type        = string
  default     = "s-2vcpu-4gb"  # 2 vCPUs, 4GB RAM
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = string
  default     = "2"
}

# terraform/main.tf
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}