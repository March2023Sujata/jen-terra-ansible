terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.48.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "test"
    storage_account_name = "remotebackendstorage"
    container_name       = "remotebackend"
    key                  = "remote.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}