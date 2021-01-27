resource "azurerm_container_registry" "acr" {
  name                     = "containerRegistryFYC"
  resource_group_name      = var.group_name
  location                 = var.location
  sku                      = "Basic"
  admin_enabled            = true
}

resource "null_resource" "push" {
  # Avec déclencheur 
  triggers = {
    regestry_created = azurerm_container_registry.acr.id
  }

  # TODO Use new resource when exists
  provisioner "local-exec" {
    command = "docker login ${azurerm_container_registry.acr.name}.azurecr.io --username ${azurerm_container_registry.acr.admin_username} --password ${azurerm_container_registry.acr.admin_password}" 
  }

  provisioner "local-exec" {
    command = "docker tag ${var.docker_image_name} ${azurerm_container_registry.acr.name}.azurecr.io/${var.docker_image_name}:latest"
  }

  provisioner "local-exec" {
    command = "docker push ${azurerm_container_registry.acr.name}.azurecr.io/${var.docker_image_name}:latest"
  }

  depends_on = [azurerm_container_registry.acr]
}