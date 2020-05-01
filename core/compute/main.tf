
locals {
  instance_count = var.no_of_vms
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.app_name}-${var.environment_name}-pip"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  count               = local.instance_count
  name                = "${var.app_name}-nic-${count.index}"
  resource_group_name = var.resource_group
  location            = var.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "avset" {
  name                         = "${var.app_name}-${var.environment_name}-avset"
  location                     = var.location
  resource_group_name          = var.resource_group
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_network_security_group" "webserver" {
  name                = "tls_webserver"
  location            = var.location
  resource_group_name = var.resource_group
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "tls"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = local.instance_count
  name                            = "${var.app_name}-${var.environment_name}-vm${count.index}"
  resource_group_name             = var.resource_group
  location                        = var.location
  size                            = "Standard_F2"
  admin_username                  = var.username
  availability_set_id             = azurerm_availability_set.avset.id
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]
 admin_ssh_key {
    username   = var.username
    public_key = file(var.admin_ssh_key)
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = var.environment_name
    app_name  = var.app_name
  }
}