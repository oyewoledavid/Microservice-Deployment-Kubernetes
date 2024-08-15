#!/bin/bash

# Get the output values from terraform
cd terraform
region=$(terraform output -raw region)
cluster_name=$(terraform output -raw cluster_name)

# Go to terraform directory and run terraform init and terraform apply
terraform init
terraform apply --auto-approve

# Get the kubeconfig file and update the kubeconfig
aws eks update-kubeconfig --region $region --name $cluster_name

#create namespace and set the context
kubectl create namespace sock-shop
kubectl config set-context --current --namespace=sock-shop
##helm create sock-shop
cd ../sock-shop
helm install sock-shop .

# Add the helm repo for ingress-nginx and install the ingress controller
helm repo add ingress https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress ingress/ingress-nginx 
cd ..
kubectl apply -f ingress.yaml

# Install cert-manager
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

kubectl apply -f certificate.yaml


helm upgrade prometheus prometheus/kube-prometheus-stack -f values.yaml