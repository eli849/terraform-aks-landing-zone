variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "sp_secret" {
  type      = string
  sensitive = true
}

variable "sp_object_id" {
  type = string
}
