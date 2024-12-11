output "cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.demo.endpoint
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.demo.kube_config[0].raw_config
  sensitive = true
}

output "argocd_ip" {
  value = data.kubernetes_service.argocd_server.status.0.load_balancer.0.ingress.0.ip
}

# Add data source to get ArgoCD service IP
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}