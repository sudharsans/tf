provider "azurerm" {
  version = "=2.0.0"
  features {}
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = var.resource_group
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["vmsubnet1"]

  tags = {
    environment = var.environment_name
    app_name  = var.app_name
  }
}
