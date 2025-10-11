resource "azurerm_key_vault" "kv" {
  name                        = "${var.rg_name}-kv"
  location                    = var.location
  resource_group_name         = var.rg_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  
  access_policy {
    tenant_id = var.tenant_id
    object_id = var.sp_object_id

    secret_permissions = [
      "get",
      "list"
    ]
  }
}


resource "azurerm_key_vault_secret" "sp_secret" {
  name         = "aks-sp-secret"
  value        = var.sp_secret
  key_vault_id = azurerm_key_vault.kv.id
}

output "kv_id" {
  value = azurerm_key_vault.kv.id
}
