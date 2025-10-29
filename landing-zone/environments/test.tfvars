# Test Environment Variables

environment          = "test"
rg_name              = "rg-aks-test"
location             = "eastus"
sp_name              = "sp-aks-test"
vnet_cidr            = ["10.1.0.0/16"]
subnet_cidr          = ["10.1.1.0/24"]
aks_cluster_name     = "aks-cluster-test"
aks_dns_prefix       = "aks-test"
node_count           = 2
vm_size              = "Standard_D2s_v3"
