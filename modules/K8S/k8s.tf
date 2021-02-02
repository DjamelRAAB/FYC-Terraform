resource "azurerm_kubernetes_cluster" "fyc" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.group_name
  dns_prefix          = "fycaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    http_application_routing {
      enabled = true
    }
  }
  
  tags = {
    Environment = "Production"
  }
}
