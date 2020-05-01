provider "azurerm" {
  features {}
}

resource "azurerm_app_service_plan" "asp" {
  name                = "${var.app_name}-${var.environment_name}-asp"
  location            = var.location
  resource_group_name = var.resource_group
  kind                = var.kind
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appservice" {
  name                ="${var.app_name}-${var.environment_name}-appservice"
  location            = var.location
  resource_group_name = var.resource_group
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    linux_fx_version = "${var.app}|${var.php_version}"
    scm_type         = "LocalGit"
  }
}