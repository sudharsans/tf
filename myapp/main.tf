
provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.app_name}-${var.environment_name}-rg"
  location = var.location
}

module "network" {
    source = "../core/network"
    environment_name = var.environment_name
    location = var.location
    app_name = var.app_name
    resource_group = azurerm_resource_group.rg.name
}

module "compute" {
    source = "../core/compute"
    environment_name = var.environment_name
    app_name = var.app_name
    location = var.location
    subnet_id = element(module.network.vnet_subnets, 0)
    username = var.username
    admin_ssh_key = var.admin_ssh_key
    no_of_vms = var.no_of_vms
    resource_group = azurerm_resource_group.rg.name
}

module "appservice" {
    source = "../core/appservice"
    environment_name = var.environment_name
    location = var.location
    app_name = var.app_name
    resource_group = azurerm_resource_group.rg.name
    php_version = var.php_version
    app = var.app
    kind = var.kind
}

module "database" {
    source = "../core/database"
    environment_name = var.environment_name
    location = var.location
    app_name = var.app_name
    resource_group = azurerm_resource_group.rg.name
    mysql_user = var.mysql_user
    mysql_password = var.mysql_password
    mysql_version = var.mysql_version
}