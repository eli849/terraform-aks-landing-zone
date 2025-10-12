output "service_principal_app_id" {
  value = module.service_principal.app_id
}

output "service_principal_password" {
  value     = module.service_principal.password
  sensitive = true
}

output "key_vault_id" {
  value = module.keyvault.kv_id
}

output "aks_cluster_name" {
  value       = module.aks.cluster_name
  description = "AKS cluster name"
}

output "acr_name" {
  value       = module.acr.name
  description = "Azure Container Registry name"
}

output "acr_login_server" {
  value       = module.acr.login_server
  description = "Azure Container Registry login server"
}