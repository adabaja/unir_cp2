resource "azurerm_container_registry" "acr" {
  name                = "acrcasopractico2adabaja"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    environment = var.prefix
  }
}
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}