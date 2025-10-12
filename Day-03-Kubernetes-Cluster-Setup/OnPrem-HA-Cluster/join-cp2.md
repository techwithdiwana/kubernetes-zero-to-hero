# On‑Prem HA — Join Second Control Plane

Use the control-plane join command from `kubeadm init` output:
```bash
sudo kubeadm join 10.0.0.100:6443 --token <TOKEN>   --discovery-token-ca-cert-hash sha256:<HASH>   --control-plane --certificate-key <CERT_KEY>
```
