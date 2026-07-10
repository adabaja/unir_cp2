# Script maestro de despliegue del Caso Práctico 2.
# Levanta el caso completo: infraestructura (Terraform), app web en
# Podman sobre la VM y app con persistencia sobre AKS (Ansible).
# Requisitos previos: az login hecho, ARM_SUBSCRIPTION_ID exportada,
# y las 2 imágenes subidas al ACR (ver README).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform"

echo "==> [1/5] Infraestructura con Terraform..."
terraform -chdir="$TF_DIR" init -input=false
terraform -chdir="$TF_DIR" apply -auto-approve

echo "==> [2/5] Credenciales del ACR desde los outputs..."
ACR_SERVER=$(terraform -chdir="$TF_DIR" output -raw acr_login_server)
ACR_USER=$(terraform -chdir="$TF_DIR" output -raw acr_admin_user)
ACR_PASSWORD=$(terraform -chdir="$TF_DIR" output -raw acr_admin_password)

echo "==> [3/5] Despliegue de app-web en Podman vía Ansible..."
ansible-playbook -i "$SCRIPT_DIR/hosts" "$SCRIPT_DIR/playbook.yml" \
  -e "acr_server=$ACR_SERVER" \
  -e "acr_user=$ACR_USER" \
  -e "acr_password=$ACR_PASSWORD"

echo "==> [4/5] Credenciales del cluster AKS..."
az aks get-credentials \
  -g rg-casopractico2 \
  -n "$(terraform -chdir="$TF_DIR" output -raw aks_name)" \
  --overwrite-existing

echo "==> [5/5] Despliegue de app-k8s con persistencia sobre AKS..."
ansible-playbook "$SCRIPT_DIR/deploy-k8s.yml" \
  -e "acr_server=$ACR_SERVER"

echo ""
echo "✅ Caso práctico desplegado."
echo "   Web Podman:  https://$(terraform -chdir="$TF_DIR" output -raw vm_public_ip)"
echo "   App K8s:     ver IP del LoadBalancer en la salida del playbook