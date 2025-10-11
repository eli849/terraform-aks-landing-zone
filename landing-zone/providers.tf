terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # use latest 3.x
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.50.0" # use latest 2.x
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = true
}

provider "azuread" {}

provider "helm" {}

provider "random" {}

# Kubernetes and Helm providers will be configured in the root module using AKS kubeconfig
/*
Kubernetes and Helm providers are configured inside the monitoring module where
they can safely consume the AKS kube_admin_config values passed via module inputs.
Provider blocks in the root must not reference module outputs because that creates
an evaluation cycle.
*/
