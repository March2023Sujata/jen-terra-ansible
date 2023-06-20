resource "azurerm_resource_group" "RG" {
  name     = "ansible-${var.rg_info.rg_name}"
  location = var.rg_info.rg_location
}

resource "azurerm_virtual_network" "VNET" {
  name                = "ansible-${var.vnet_info.vnet_name}"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  address_space       = var.vnet_info.vnet_address
  depends_on = [
    azurerm_resource_group.RG
  ]
}

resource "azurerm_subnet" "SUB_NET" {
  count                = length(var.vnet_info.subnet_names)
  name                 = "ansible-${var.vnet_info.subnet_names[count.index]}"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = [cidrsubnet(var.vnet_info.vnet_address[0], 8, count.index)]
  depends_on = [
    azurerm_virtual_network.VNET
  ]
}