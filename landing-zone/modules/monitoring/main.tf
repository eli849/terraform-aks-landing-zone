// variables are declared in variables.tf

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "45.0.0" # pin a reasonable chart version; adjust as needed

  values = [templatefile("${path.module}/values.yaml.tpl", {
    grafana_admin_password = var.grafana_admin_password
  })]
}

# store grafana admin password in Key Vault
resource "azurerm_key_vault_secret" "grafana_admin" {
  name         = var.grafana_admin_password_secret_name
  value        = var.grafana_admin_password
  key_vault_id = var.key_vault_id
}

output "grafana_release_name" {
  value = helm_release.kube_prometheus_stack.name
}
