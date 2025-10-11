variable "key_vault_id" {
  type = string
}

variable "grafana_admin_password" {
  type = string
  sensitive = true
}

variable "grafana_admin_password_secret_name" {
  type    = string
  default = "grafana-admin-password-secret-name"
}
