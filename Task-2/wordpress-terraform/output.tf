output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

variable "create_public_ip" {
  type    = bool
  default = true
}
