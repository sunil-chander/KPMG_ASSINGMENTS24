variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "wordpress-rg"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "East US"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password"
  type        = string
  default     = "Password123!"
}
