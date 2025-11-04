
minikube start --cpus=4 --memory=6g
minikube addons enable ingress
minikube addons enable storage-provisioner
Write-Host "Minikube + Ingress + Storage ready."
