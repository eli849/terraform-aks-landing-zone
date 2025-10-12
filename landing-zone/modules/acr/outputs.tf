output "login_server" {
  description = "The login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "resource_id" {
  description = "The resource ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "admin_username" {
  description = "The admin username for ACR (only valid if admin_enabled=true)"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "The admin password for ACR (only valid if admin_enabled=true)"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "name" {
  value       = azurerm_container_registry.acr.name
  description = "The name of the Azure Container Registry"
}
