#!/bin/bash

set -euo pipefail

ARGO_NS=argocd
MON_NS=monitoring
# INGRESS_NS=ingress-nginx

# echo "🔥Installing Ingress-nginx controller..."

# # Create namespace
# kubectl create namespace $INGRESS_NS || true

# # Add Helm repo
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update

# # Install ingress-nginx
# helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
#   --namespace $INGRESS_NS \
#   --set controller.service.type=LoadBalancer



echo "🚀 Installing ArgoCD..."

# Add Argo Helm repo
helm repo add argo https://argoproj.github.io/argo-helm || true
helm repo update

# Create namespace
kubectl create namespace $ARGO_NS || true

# Install ArgoCD
helm upgrade --install argocd argo/argo-cd -n $ARGO_NS

# Wait for ArgoCD server to be ready
echo "⏳ Waiting for ArgoCD server to be ready..."
kubectl rollout status deployment/argocd-server -n $ARGO_NS

# Delete default service if exists
kubectl delete svc argocd-server -n $ARGO_NS || true

# Create LoadBalancer service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: argocd-server
  namespace: $ARGO_NS
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: argocd-server
    app.kubernetes.io/part-of: argocd
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
EOF

echo "📈 Installing Prometheus + Grafana..."

# Add Prometheus repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update

kubectl create namespace $MON_NS || true

# Install Prometheus + Grafana
helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
  --namespace $MON_NS \
  --set grafana.enabled=true \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# Expose Grafana
kubectl expose service kube-prom-stack-grafana \
  --type=LoadBalancer \
  --name=grafana-lb \
  --port=80 \
  --target-port=3000 \
  -n $MON_NS || true

# Expose Prometheus
kubectl expose service kube-prom-stack-kube-prome-prometheus \
  --type=LoadBalancer \
  --name=prometheus-lb \
  --port=80 \
  --target-port=9090 \
  -n $MON_NS || true



echo "✅ Done! Fetch LoadBalancer IPs below:"
kubectl get svc -n $ARGO_NS argocd-server
kubectl get svc -n $MON_NS grafana-lb
kubectl get svc -n $MON_NS prometheus-lb
kubectl get svc -n ingress-nginx


# /integration → integration-app-service

# /random → random-num-gen-service

# /grafana → kube-prom-stack-grafana

# /prometheus → kube-prom-stack-kube-prome-prometheus

# /argocd → argocd-server