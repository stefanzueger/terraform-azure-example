variable "environment" {
  default = "dev"
}

variable "resource_group_name" {
  default = "terraformexample-rg-dev"
}

variable "default_tags" {
  default = {
    environment = "dev"
  }
}
