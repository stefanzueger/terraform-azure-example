terraform {
  backend "azurerm" {
    resource_group_name = "terraformexample-infrastructure"
    storage_account_name = "terraformexampleinfrastructure"
    container_name = "tfstate"
    key = "dev.tfstate"
  }
}

provider "azurerm" {
  version = "=1.22.0"
}

module "main" {
  source = "../../resources"

  environment = "dev"
  resource_group_name = "terraformexample-rg-dev"
}