resource "azuread_application" "aks_app" {
  display_name = var.sp_name
}

resource "azuread_service_principal" "aks_sp" {
  client_id = azuread_application.aks_app.client_id
}

resource "azuread_service_principal_password" "aks_sp_password" {
  service_principal_id = azuread_service_principal.aks_sp.id
  end_date = timeadd(timestamp(), "8760h") # 1 year
}

resource "azurerm_role_assignment" "sp_contributor" {
  scope                = var.rg_id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks_sp.id

  depends_on = [
    azuread_service_principal.aks_sp,
    azuread_service_principal_password.aks_sp_password
  ]

  timeouts {
    create = "5m"
  }
}

output "app_id" {
  value = azuread_application.aks_app.client_id
}

output "password" {
  value     = azuread_service_principal_password.aks_sp_password.value
  sensitive = true
}

output "principal_id" {
  value = azuread_service_principal.aks_sp.id
}
