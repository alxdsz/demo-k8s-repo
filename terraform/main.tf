resource "digitalocean_kubernetes_cluster" "demo" {
  name    = var.cluster_name
  region  = var.region
  version = "1.31.1-do.5"

  node_pool {
    name       = "worker-pool"
    size       = var.node_size
    node_count = var.node_count
  }
}

# Configure kubernetes provider
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.demo.endpoint
  token = digitalocean_kubernetes_cluster.demo.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.demo.kube_config[0].cluster_ca_certificate
  )
}

# Configure helm provider
provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.demo.endpoint
    token = digitalocean_kubernetes_cluster.demo.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.demo.kube_config[0].cluster_ca_certificate
    )
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.9"

  values = [
    <<-EOT
    server:
      service:
        type: LoadBalancer
    configs:
      params:
        server.insecure: true
    EOT
  ]

  depends_on = [digitalocean_kubernetes_cluster.demo]
}