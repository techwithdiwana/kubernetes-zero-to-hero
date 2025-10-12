# Run in PowerShell (Administrator)
choco install minikube -y
minikube start --driver=docker --kubernetes-version=v1.30.0
minikube addons enable ingress
minikube addons enable metrics-server
