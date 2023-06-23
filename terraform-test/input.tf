variable "rg_info" {
  type = object({
    rg_name     = string,
    rg_location = string
  })
  default = {
    rg_name     = "rg"
    rg_location = "eastus"
  }
}

variable "vnet_info" {
  type = object({
    vnet_name     = string,
    vnet_address  = list(string),
    subnet_names  = list(string),
    publicIP_name = string,
    allocation    = string
  })
  default = {
    vnet_name     = "vnet"
    vnet_address  = ["192.168.0.0/16"]
    subnet_names  = ["app"]
    publicIP_name = "publicIP"
    allocation    = "Dynamic"
  }
}

variable "nic_info" {
  type = object({
    nic_name  = string,
    ip_config = string,
    nsg_name  = string
  })
  default = {
    nic_name  = "nic"
    ip_config = "ip_config"
    nsg_name  = "nsg"
  }
}

variable "vm_info" {
  type = object({
    vm_name              = string,
    vm_size              = string,
    admin                = string,
    disk_name            = string,
    caching              = string,
    storage_account_type = string
  })
  default = {
    vm_name              = "vm"
    vm_size              = "Standard_B1s"
    admin                = "adminuser"
    disk_name            = "osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}