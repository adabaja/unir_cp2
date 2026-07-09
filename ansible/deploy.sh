# Script maestro de despliegue del Caso Práctico 2.
# Fase actual: infraestructura (Terraform) + app web en Podman (Ansible).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform"

echo "==> [1/3] Infraestructura con Terraform..."
terraform -chdir="$TF_DIR" init -input=false
terraform -chdir="$TF_DIR" apply -auto-approve

echo "==> [2/3] Credenciales del ACR desde los outputs..."
ACR_SERVER=$(terraform -chdir="$TF_DIR" output -raw acr_login_server)
ACR_USER=$(terraform -chdir="$TF_DIR" output -raw acr_admin_user)
ACR_PASSWORD=$(terraform -chdir="$TF_DIR" output -raw acr_admin_password)

echo "==> [3/3] Despliegue de app-web en Podman vía Ansible..."
ansible-playbook -i "$SCRIPT_DIR/hosts" "$SCRIPT_DIR/playbook.yml" \
  -e "acr_server=$ACR_SERVER" \
  -e "acr_user=$ACR_USER" \
  -e "acr_password=$ACR_PASSWORD"

echo "✅ Completado. Web: https://$(terraform -chdir="$TF_DIR" output -raw vm_public_ip)"