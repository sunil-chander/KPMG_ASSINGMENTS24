# Define the resource group
resource "azurerm_resource_group" "kpmg-rg" {
  name     = var.resource_group_name
  location = var.location
}

# Define the virtual network
resource "azurerm_virtual_network" "kpmg-vnet2" {
  name                = "wordpress-vnet3"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name
}

# Define the subnet
resource "azurerm_subnet" "kpmg-subnet" {
  name                 = "wordpress-subnet"
  resource_group_name  = azurerm_resource_group.kpmg-rg.name
  virtual_network_name = azurerm_virtual_network.kpmg-vnet2.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the public IP address
resource "azurerm_public_ip" "pip" {
  name                = "wordpress-pip3"
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name
  allocation_method   = "Dynamic"
}

# Define the network interface
resource "azurerm_network_interface" "kpmg-nic" {
  name                = "wordpress-nic2"
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kpmg-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Define the network security group
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

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.kpmg-nic.id
  network_security_group_id = azurerm_network_security_group.kpmg-nsg2.id
}

# Define the virtual machine
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

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y apache2 mysql-server php php-mysql libapache2-mod-php",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2",
      "curl -O https://wordpress.org/latest.tar.gz",
      "tar -xzf latest.tar.gz",
      "sudo cp -r wordpress/* /var/www/html/",
      "sudo chown -R www-data:www-data /var/www/html/",
      "sudo chmod -R 755 /var/www/html/",
      "sudo systemctl restart apache2"
    ]
  }
}

# Output the public IP address
output "public_ip_address" {
  value = azurerm_public_ip.pip.ip_address
}
