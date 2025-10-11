variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type = list(string)
}

variable "subnet_cidr" {
  type = list(string)
}
