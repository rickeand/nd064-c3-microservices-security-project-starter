

## Get the Helm script, change the permissions, and execute
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh
helm version

helm repo add falcosecurity https://falcosecurity.github.io/charts
## Update the Helm repo to get the latest charts
helm repo update
## Falco deployment
helm install --kubeconfig kube_config_cluster.yml falco falcosecurity/falco --namespace falco --create-namespace --set falco.grpc.enabled=true --set falco.grpc_output.enabled=true
helm install --kubeconfig kube_config_cluster_hardened.yml falco falcosecurity/falco --namespace falco --create-namespace --set falco.grpc.enabled=true --set falco.grpc_output.enabled=true

# check health
## View the new falco namespace
kubectl --kubeconfig kube_config_cluster.yml get namespace
## The falco pod must be READY and in Running STATUS
kubectl --kubeconfig kube_config_cluster.yml get pods --namespace falco
kubectl --kubeconfig kube_config_cluster_hardened.yml get pods --namespace falco

## Ensure that Falco is deployed as a DaemonSet. It should show 1 READY.
kubectl --kubeconfig kube_config_cluster_hardened.yml get ds --namespace falco
kubectl --kubeconfig kube_config_cluster_hardened.yml get ds falco --namespace falco -o yaml | grep serviceAcc

# bash falco
sudo kubectl --kubeconfig kube_config_cluster.yml exec --stdin -it falco-jw9nq --namespace falco -- /bin/bash

cat /etc/falco/falco.yaml
#grpc:
 #	enabled: true
 #grpc_output:
 #	enabled: true

kubectl apply --kubeconfig kube_config_cluster.yml  --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/v1.3.1/cert-manager.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
## Install the cert-manager Helm chart
helm install --kubeconfig kube_config_cluster.yml cert-manager jetstack/cert-manager  --namespace cert-manager --create-namespace --version v1.3.1

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
## Install kube-prometheus-stack, specific version
helm install --kubeconfig kube_config_cluster.yml prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace --generate-name  --version 18.0.8

helm repo update
helm install --kubeconfig kube_config_cluster.yml falco-exporter --namespace falco --set serviceMonitor.enabled=true falcosecurity/falco-exporter

## Check your Falco exporter release name
helm list --kubeconfig kube_config_cluster.yml --all --all-namespaces
## Verify the pod status
kubectl --kubeconfig kube_config_cluster.yml get pods -A

kubectl --kubeconfig kube_config_cluster.yml port-forward --namespace falco falco-exporter-cmx7f 9376
kubectl --kubeconfig kube_config_cluster.yml --namespace monitoring port-forward service/kube-prometheus-stack-1698-prometheus 9090:9090

kubectl --kubeconfig kube_config_cluster.yml logs falco-jw9nq --namespace falco | grep etc/shadow
