output "cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.demo.endpoint
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.demo.kube_config[0].raw_config
  sensitive = true
}

output "ingress_ip" {
  value = data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.ip
}

output "argocd_url" {
  value = "https://argocd.${data.kubernetes_service.ingress_nginx.status.0.load_balancer.0.ingress.0.ip}.nip.io"
}