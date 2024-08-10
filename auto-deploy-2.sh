#/bin/bash

# Apply the ClusterIssuer
kubectl apply -f cluster-issuer.yaml

# Apply the Ingress file
kubectl apply -f ingress.yaml

# Apply the Certificate file
kubectl apply -f certificate.yaml