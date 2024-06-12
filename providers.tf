terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.95.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.12.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"

    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "2.27.0"
    # }

  }
  // save state file in blob container , needs to be created manually or via createBlob.sh script
  # backend "azurerm" {
  #   resource_group_name  = "rg-aleksandar-ilicic"
  #   storage_account_name = "tfstate29864"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }

   backend "azurerm" {
     resource_group_name  = "rg-aleksandar-ilicic"
     storage_account_name = "tfstate29864"
     container_name       = "azuredevops"
     key                  = "terraform.tfstate"
   }
}

provider "azurerm" {
  features {}
}

# provider "kubernetes" {
#   # Terraform uses the default kubeconfig path (~/.kube/config) and context
#   config_path = "~/.kube/config"
# }