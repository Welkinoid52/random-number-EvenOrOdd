/integration → integration-app-service **MAIN**
/random      → random-num-gen-service
/argocd
/grafana
/prometheus

--------------------------------------------------------------------------------------------------------------
GRAFANA LOGIN

kubectl get secret --namespace monitoring kube-prom-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

DEFAULT PWD= prom-operator
---------------------------------------------------------------------------------------------------------------
ARGOCD LOGIN

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

----------------------------------------------------------------------------------------------------------------
DOWNLOAD METRIC server

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
-----------------------------------------------------------------------------------------------------------------

eksctl create iamserviceaccount \
    --cluster=demo-cluster \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::650234510693:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region us-east-1 \
    --approve


helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=demo-cluster \
  --set region=us-east-1 \
  --set vpcId=vpc-0a54bb4ee9f80665a \                      
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --wait


# give node permission
    aws eks describe-nodegroup \
  --cluster-name demo-cluster \
  --nodegroup-name default-20250609140918918300000011 \
  --query "nodegroup.nodeRole" \
  --output text
--------------------------------------------------------------------------------------------------

# Define namespace
ARGO_NS=argocd
echo "🚀 Installing ArgoCD..."
helm repo add argo https://argoproj.github.io/argo-helm || true
helm repo update
kubectl create namespace $ARGO_NS || true
helm upgrade --install argocd argo/argo-cd \
  -n $ARGO_NS \
  --set server.service.type=ClusterIP \
  --wait

------------------------------------------------------------------------

MON_NS="monitoring"
echo "📊 Installing Prometheus + Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
kubectl create namespace $MON_NS || true
helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
  -n $MON_NS \
  --set grafana.service.type=ClusterIP \
  --set prometheus.service.type=ClusterIP \
  --wait
