data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

module "service_principal" {
  source  = "./modules/service_principal"
  sp_name = var.sp_name
  rg_id   = azurerm_resource_group.rg.id
}

module "network" {
  source      = "./modules/network"
  rg_name     = azurerm_resource_group.rg.name
  location    = var.location
  vnet_cidr   = var.vnet_cidr
  subnet_cidr = var.subnet_cidr
}

module "keyvault" {
  source        = "./modules/keyvault"
  rg_name       = azurerm_resource_group.rg.name
  location      = var.location
  tenant_id     = data.azurerm_client_config.current.tenant_id
  sp_secret     = module.service_principal.password
  sp_object_id  = module.service_principal.principal_id
}

module "aks" {
  source         = "./modules/aks"
  rg_name        = azurerm_resource_group.rg.name
  location       = var.location
  vnet_subnet_id = module.network.subnet_id
  sp_app_id      = module.service_principal.app_id
  sp_secret      = module.service_principal.password
  cluster_name   = var.aks_cluster_name
  dns_prefix     = var.aks_dns_prefix
  node_count     = var.node_count
  vm_size        = var.vm_size
}

module "acr" {
  source              = "./modules/acr"
  acr_name            = "myacr"                            # Replace with your desired ACR name (must be globally unique)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  acr_sku             = "Basic"
  admin_enabled       = true
  tags                = {
    environment = "dev"
    project     = "landing-zone"
  }
}

resource "random_password" "grafana_admin" {
  length  = 16
  special = true
}

locals {
  kube = module.aks.kube_admin_config
}

module "monitoring" {
  source = "./modules/monitoring"
  key_vault_id = module.keyvault.kv_id
  grafana_admin_password = random_password.grafana_admin.result
  depends_on = [module.aks]
}

output "kube_provider_host" {
  value     = local.kube.host
  sensitive = true
}

output "kube_provider_client_certificate" {
  value     = local.kube.client_certificate
  sensitive = true
}

output "kube_provider_client_key" {
  value     = local.kube.client_key
  sensitive = true
}

output "kube_provider_cluster_ca_certificate" {
  value     = local.kube.cluster_ca_certificate
  sensitive = true
}
