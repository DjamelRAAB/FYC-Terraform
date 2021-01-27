terraform {
  required_version = ">= 0.12.0"
  required_providers {
    azurerm = ">=2.0.0"
  }
}

provider "azurerm" {
  version = ">=2.0.0"
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

provider "azuread" {
  version = "~>0.7"
}

provider "random" {
}

# define the password
resource "random_string" "aks_fyc_secret" {
  length  = 32
  special = true
}

locals {
  location = "francecentral"
  group_name = "FYC"
  cluster_name = "AKS-FYC"
  docker_image_name = "nginx" # à changer !!! 
}

resource "azuread_application" "aks_fyc" {
  name = "sp-aks-${local.cluster_name}"
}

resource "azuread_service_principal" "aks_fyc" {
  application_id               = azuread_application.aks_fyc.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "aks_fyc" {
  service_principal_id = azuread_service_principal.aks_fyc.id
  value                = random_string.aks_fyc_secret.result
  end_date_relative    = "8760h" # 1 year

  lifecycle {
    ignore_changes = [
      value,
      end_date_relative
    ]
  }
}

resource "azuread_application_password" "aks_fyc" {
  application_object_id = azuread_application.aks_fyc.id
  value                 = random_string.aks_fyc_secret.result
  end_date_relative     = "8760h" # 1 year

  lifecycle {
    ignore_changes = [
      value,
      end_date_relative
    ]
  }
}

resource "azurerm_resource_group" "fyc" {
  name     = local.group_name
  location = local.location
}

module "registry" {
  source = "./modules/Registry"
  location = local.location
  group_name = local.group_name
  docker_image_name = local.docker_image_name
}
resource "azurerm_role_assignment" "aks_fyc_container_registry" {
  scope                = module.registry.azurerm_container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.aks_fyc.object_id
}

module "aks" {
  source = "./modules/K8S"
  location = local.location
  group_name = local.group_name
  cluster_name = local.cluster_name
  client_id     = azuread_service_principal.aks_fyc.application_id
  client_secret = random_string.aks_fyc_secret.result
}
