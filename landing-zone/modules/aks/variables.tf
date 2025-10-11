variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_subnet_id" {
  type = string
}

variable "sp_app_id" {
  type = string
}

variable "sp_secret" {
  type      = string
  sensitive = true
  default   = ""
}
