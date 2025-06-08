/ → integration-app-service **MAIN**

/random → random-num-gen-service

----------------------------------------------------------------------------------
GRAFANA LOGIN

kubectl get secret --namespace monitoring kube-prom-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

DEFAULT PWD= prom-operator
----------------------------------------------------------------------------------
ARGOCD LOGIN

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

-----------------------------------------------------------------------------------