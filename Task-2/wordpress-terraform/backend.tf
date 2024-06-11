terraform {
  backend "azurerm" {
    resource_group_name   = "sql-rg"
    storage_account_name  = "terrastatefilebighand"
    container_name        = "kpmgcontainer"
    key                   = "kpmg/kpmg.terraform.tfstate"
  }
}
