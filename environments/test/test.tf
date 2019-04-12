terraform {
  backend "azurerm" {
    resource_group_name = "terraformexample-infrastructure"
    storage_account_name = "terraformexampleinfrastructure"
    container_name = "tfstate"
    key = "test.tfstate"
  }
}

provider "azurerm" {
  version = "=1.22.0"
}

module "main" {
  source = "../../resources"

  environment = "test"
  resource_group_name = "terraformexample-test"

  default_tags = {
    environment = "test"
  }
}