terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.88.0"
    }
  }
}

# provider details
provider "azurerm" {
  features {}
}

