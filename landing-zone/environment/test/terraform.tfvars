#subscription_id = "99999999-xxxx-yyyy-zzzz-888888888888"

#provider "azurerm" {
  features = {}
  use_msi  = true
  subscription_id = var.subscription_id
#}


#terraform.tfvars!!!! – where you assign values to the variables declared in variables.tf.
# prod/terraform.tfvars
#subscription_id = "9999-xxxx-yyyy-zzzz"
#location        = "westus2"

#output.tf!!! is your receipt — what you got and the details about your purchase.
#URI/AKS NAME - To expose useful information about deployed infrastructure to humans or automation tools.

#"BLUEPRINT" — it tells Terraform what inputs it should expect, and optionally gives defaults.
# prod/variables.tf
#variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
#}

#variable "location" {
#  description = "Azure region"
#  type        = string
  default     = "westus"
#}
