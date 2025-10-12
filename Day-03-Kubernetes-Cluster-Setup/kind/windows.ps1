# Run in PowerShell (Administrator)
choco install kind -y
kind create cluster --name dev --config kind/kind-config.yaml
