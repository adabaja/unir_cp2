# Cluster de Kubernetes gestionado (AKS) — Criterio 3.
# Un único node pool con 1 nodo: es el "único worker" que pide el enunciado.
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${var.prefix}"
  sku_tier            = "Free"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"   # el system pool exige >=2 vCPU/4GiB y no admite serie B
  }

  # Identidad gestionada: Azure crea y rota las credenciales del cluster
  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.prefix
  }
}

# Permiso de solo-lectura de imágenes sobre MI ACR para el kubelet del cluster:
# los nodos pueden hacer pull sin usuario/contraseña (mejor que credenciales admin)
resource "azurerm_role_assignment" "aks_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

# Nombre del cluster, para get-credentials
output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}