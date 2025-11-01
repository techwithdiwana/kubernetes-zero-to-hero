@echo off
echo === Creating Namespace ===
kubectl apply -f ns.yaml

echo === Creating ConfigMap ===
kubectl apply -f cm.yaml

echo === Creating Deployment ===
kubectl apply -f deploy.yaml

echo === Creating Service ===
kubectl apply -f svc.yaml

echo === Creating Secret ===
kubectl apply -f secret.yaml

echo === Waiting for Pods ===
kubectl wait --for=condition=available deployment/web -n day8-lab --timeout=90s

echo === Forwarding Service to localhost:8080 ===
start cmd /k "kubectl -n day8-lab port-forward svc/web 8080:80"
echo.
echo Application is ready! Visit http://localhost:8080
pause
