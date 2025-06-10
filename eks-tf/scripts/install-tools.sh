#!/bin/bash
set -euo pipefail

CLUSTER_NAME="demo-cluster"
ARGO_NS="argocd"
MON_NS="monitoring"
AWS_REGION="us-east-1"

echo "🔧 Installing AWS Load Balancer Controller..."

# Add Helm repo and update
helm repo add eks https://aws.github.io/eks-charts || true
helm repo update

# Install CRDs (corrected URL)
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

# Install controller with recommended settings
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$AWS_REGION \  # Important for some configurations
  --wait


echo "🚀 Installing ArgoCD..."
helm repo add argo https://argoproj.github.io/argo-helm || true
helm repo update
kubectl create namespace $ARGO_NS || true

helm upgrade --install argocd argo/argo-cd \
  -n $ARGO_NS \
  --set server.service.type=ClusterIP \
  --wait

echo "📊 Installing Prometheus + Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
kubectl create namespace $MON_NS || true

helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
  -n $MON_NS \
  --set grafana.service.type=ClusterIP \
  --set prometheus.service.type=ClusterIP \
  --wait
