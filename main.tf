resource "azuread_user" "user-1" {
  user_principal_name = "matthew@example.com"
  display_name        = "Matthew"
  password            = var.password
}

resource "azuread_user" "user-2" {
  user_principal_name   = "ibrahim@example.com"
  display_name          = "Ibrahim"
  password              = var.password
  force_password_change = true
}

resource "aws_iam_user" "new-users" {
  for_each = toset(var.users)
  name     = each.value
}

resource "aws_s3_bucket" "s3" {
  count  = 2
  bucket = "S3-Bucket-192b2-${count.index}"
  tags = {
    environment = var.environment
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "project-1-rg"
  location = "East US"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "azurestoragepj120398"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "main" {
  name                = "project1-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "project1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "project1-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ubuntu"
    admin_username = "vmadmin"
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.environment
  }
}

output "vm_network_interface_id" {
    value = azurerm_virtual_machine.main.network_interface_ids
}