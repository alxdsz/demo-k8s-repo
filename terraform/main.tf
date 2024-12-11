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

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.8.3"  # Check for latest version

  values = [
    <<-EOT
    controller:
      service:
        annotations:
          service.beta.kubernetes.io/do-loadbalancer-name: "${var.cluster_name}-ingress"
    admissionWebhooks:
      enabled: false    # Disable webhook for demo purposes only
    EOT
  ]

  depends_on = [digitalocean_kubernetes_cluster.demo]
}

# Data source to get the LoadBalancer IP
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.ingress_nginx]
}

# Now modify ArgoCD installation to use Ingress
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.51.6"

  values = [
    <<-EOT
    server:
      ingress:
        enabled: true
        ingressClassName: nginx
        hosts:
          - argocd.${data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.ip}.nip.io
      service:
        type: ClusterIP
    configs:
      params:
        server.insecure: true
    EOT
  ]

  depends_on = [helm_release.ingress_nginx]
}