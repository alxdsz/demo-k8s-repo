# Kubernetes Demo Environment

This repository contains simple infrastructure code and Kubernetes manifests for a small Kubernetes introduction demo. 
It sets up a DigitalOcean cluster with ArgoCD and a few demo applications.

## Prerequisites

- OpenTofu (https://opentofu.org/)
- kubectl
- A DigitalOcean account and API token

## Instructions

### 1. Initial Setup

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/demo-k8s-repo.git
cd demo-k8s-repo
```

2. Create terraform.tfvars:
```bash
cp terraform/terraform.tfvars.template terraform/terraform.tfvars
```

3. Edit terraform.tfvars and add your DigitalOcean token:
```hcl
do_token = "your-token-here"
```

### 2. Spin up the cluster

1. Initialize and apply Terraform:
```bash
cd terraform
terraform init
terraform apply
```

2. Configure kubectl:
```bash
terraform output -raw kubeconfig > ~/.kube/config
```

### 3. Access ArgoCD

1. Get the ArgoCD IP:
```bash
terraform output argocd_ip
```

2. Get the initial admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

3. Access ArgoCD UI:
- URL: http://<argocd_ip>
- Username: admin
- Password: (see step 2)

### 4. Deploy KubeInvaders

1. Update GitHub repository URL in argocd/apps/kubeinvaders/application.yaml if needed

2. Apply KubeInvaders Application:
```bash
kubectl apply -f argocd/apps/kubeinvaders/application.yaml
```

3. Wait for the application to sync in ArgoCD UI

4. Get KubeInvaders IP:
```bash
kubectl -n kubeinvaders get svc kubeinvaders -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
