provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_mysql_server" "mysql" {
  name                = "${var.app_name}-${var.environment_name}-mysql"
  location            = var.location
  resource_group_name = var.resource_group

  sku_name = "B_Gen5_2"

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = var.mysql_user
  administrator_login_password = var.mysql_password
  version                      = var.mysql_version
  ssl_enforcement              = "Enabled"
}

resource "azurerm_mysql_database" "mysql_db" {
  name                = "${var.app_name}-${var.environment_name}-mysql-server"
  resource_group_name = var.resource_group
  server_name         = "${var.app_name}-${var.environment_name}-mysql-server"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}