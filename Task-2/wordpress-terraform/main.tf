resource "azurerm_resource_group" "kpmg-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "kpmg-vnet2" {
  name                = "wordpress-vnet3"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name
}

resource "azurerm_subnet" "kpmg-subnet" {
  name                 = "wordpress-subnet"
  resource_group_name  = azurerm_resource_group.kpmg-rg.name
  virtual_network_name = azurerm_virtual_network.kpmg-vnet2.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "kpmg-nic" {
  name                = "wordpress-nic2"
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kpmg-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "kpmg-nsg2" {
  name                = "wordpress-nsg3"
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.kpmg-nic.id
  network_security_group_id = azurerm_network_security_group.kpmg-nsg2.id
}

resource "azurerm_public_ip" "pip" {
  count               = var.create_public_ip ? 1 : 0
  name                = "wordpress-pip3"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.kpmg-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_machine" "kpmg-vm1" {
  name                  = "wordpress-vm"
  location              = azurerm_resource_group.kpmg-rg.location
  resource_group_name   = azurerm_resource_group.kpmg-rg.name
  network_interface_ids = [azurerm_network_interface.kpmg-nic.id]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "wordpress-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "wordpressvm"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_public_ip.pip.ip_address
  }
}

