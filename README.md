# Caso Práctico 2 — Automatización de despliegues en Azure

## Estructura del repositorio
    terraform/   → infraestructura (RG, ACR, red, VM, AKS)
    ansible/     → playbooks (Podman y K8s), inventario generado, deploy.sh
    app-web/     → imagen web para Podman (nginx + TLS + htpasswd)
    app-k8s/     → imagen para Kubernetes (Flask, campo + historial)
    evidencias/  → capturas del proceso

## Requisitos previos
- Azure CLI con sesión iniciada (`az login`)
- `export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"`
- Terraform, Ansible (+ colecciones containers.podman y kubernetes.core, pip kubernetes), Podman, kubectl
- Clave SSH (indicar cómo ajustar las rutas en terraform/vars.tf si difiere)

## Despliegue
1. Crear la infraestructura:  cd terraform && terraform init && terraform plan && terraform apply
2. Construir y subir las 2 imágenes al ACR (comandos build --platform + login + push)
3. Ejecutar el script maestro:  ./ansible/deploy.sh

## Verificación
- Web Podman: https://<IP-de-la-VM> (usuario/contraseña de demostración: admin / casopractico2)
- App K8s: http://<IP-del-LoadBalancer> (la imprime el playbook)
