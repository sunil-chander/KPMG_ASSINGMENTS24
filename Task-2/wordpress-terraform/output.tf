variable "create_public_ip" {
  type    = bool
  default = true
}

output "public_ip" {
  value = azurerm_public_ip.pip[0].ip_address
}

