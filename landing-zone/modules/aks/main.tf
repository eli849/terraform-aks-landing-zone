resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster"
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "aksdemo"

  default_node_pool {
    name       = "system"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = var.vnet_subnet_id
  }

  service_principal {
    client_id     = var.sp_app_id
    client_secret = var.sp_secret
  }

  identity {
    type = "SystemAssigned"
  }
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_admin_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_admin_config[0]
  sensitive = true
}
