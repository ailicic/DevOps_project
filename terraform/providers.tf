terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.95.0"
    }
  }

  // save state file in blob container , needs to be created manually or via createBlob.sh script
  backend "azurerm" {
    resource_group_name  = "rg-aleksandar-ilicic"
    storage_account_name = "tfstate29864"
    container_name       = "devopsproject"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}