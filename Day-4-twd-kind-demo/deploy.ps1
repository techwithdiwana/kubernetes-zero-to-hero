Param(
    [string]$ClusterName = "twd-cluster",
    [string]$KindConfig = ".\kind\twd-kind-2cp-2w.yaml",
    [string]$ImageTag   = "twd-web:1.0"
)

Write-Host "Step 1/6: Create Kind cluster ($ClusterName) with 2 control-planes and 2 workers..." -ForegroundColor Cyan
kind delete cluster --name $ClusterName 2>$null | Out-Null
kind create cluster --config $KindConfig | Out-Null

Write-Host "Step 2/6: Build the Docker image ($ImageTag)..." -ForegroundColor Cyan
docker build -t $ImageTag .\app

Write-Host "Step 3/6: Load the image into the Kind nodes..." -ForegroundColor Cyan
kind load docker-image $ImageTag --name $ClusterName

Write-Host "Step 4/6: Deploy to Kubernetes..." -ForegroundColor Cyan
kubectl apply -f .\k8s\deployment-and-service.yaml

Write-Host "Step 5/6: Wait for rollout..." -ForegroundColor Cyan
kubectl rollout status deploy/twd-web

Write-Host "Step 6/6: Access options" -ForegroundColor Cyan
Write-Host "Option A (recommended): kubectl port-forward service/twd-web 8080:80" -ForegroundColor Yellow
Write-Host "Then open http://localhost:8080" -ForegroundColor Yellow
Write-Host "Option B (NodePort): Open http://localhost:30080 (may require Docker Desktop port mapping on Windows)" -ForegroundColor Yellow
