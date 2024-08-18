#!/bin/bash

# Get the output values from terraform
cd terraform
region=$(terraform output -raw region)
cluster_name=$(terraform output -raw cluster_name)

# Go to terraform directory and run terraform init and terraform apply
terraform init
terraform apply --auto-approve
terraform refresh

# Get the kubeconfig file and update the kubeconfig file, this will set the context to the cluster
aws eks update-kubeconfig --region $region --name $cluster_name

#create namespace and set it as the current namespace for the cluster 
kubectl create namespace sock-shop
kubectl config set-context --current --namespace=sock-shop
##helm create sock-shop 
cd ../sock-shop
helm install sock-shop .

# Add the helm repo for ingress-nginx and install the ingress controller for the cluster this will create a classic load balancer on AWS
helm repo add ingress https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress ingress/ingress-nginx 
# Apply the ingress file to create the ingress
kubectl apply -f ingress.yaml

#  Add jetstack repo and Install cert-manager for encryption and https
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.6.3 \
  --set installCRDs=true

# Apply the cluster issuer file to create the cluster issuer
kubectl apply -f cluster-issuer.yaml

# Add the helm repo for prometheus and install prometheus for prometheus, grafana and alertmanager
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus/kube-prometheus-stack

# Apply the certificate file to create the certificate

kubectl apply -f certificate.yaml
