resource "azurerm_public_ip" "P_IP" {
  name                = "ansible-${var.vnet_info.publicIP_name}"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = var.vnet_info.allocation
  depends_on = [
    azurerm_virtual_network.VNET,
    azurerm_subnet.SUB_NET
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_interface" "NIC" {
  name                = "ansible-${var.nic_info.nic_name}"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location

  ip_configuration {
    name                          = "ansible-${var.nic_info.ip_config}"
    subnet_id                     = azurerm_subnet.SUB_NET[0].id
    private_ip_address_allocation = var.vnet_info.allocation
    public_ip_address_id          = azurerm_public_ip.P_IP.id
  }
  depends_on = [
    azurerm_virtual_network.VNET,
    azurerm_subnet.SUB_NET,
    azurerm_public_ip.P_IP
  ]
}

resource "azurerm_network_security_group" "NSG" {
  name                = "ansible-${var.nic_info.nsg_name}"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location

  security_rule {
    name                       = "All"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.NIC.id
  network_security_group_id = azurerm_network_security_group.NSG.id
  depends_on = [
    azurerm_network_interface.NIC,
    azurerm_network_security_group.NSG
  ]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "pem_key" {
  content = tls_private_key.ssh_key.private_key_pem
  filename = "ansible.pem"
  file_permission = "0600"
  depends_on = [ tls_private_key.ssh_key ]
}

resource "azurerm_linux_virtual_machine" "VM" {
  name                = "ansible-${var.vm_info.vm_name}"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = var.vm_info.vm_size
  admin_username      = var.vm_info.admin
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.NIC.id]

  admin_ssh_key {
    username   = var.vm_info.admin
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    name                 = "ansible-${var.vm_info.disk_name}"
    caching              = var.vm_info.caching
    storage_account_type = var.vm_info.storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  user_data = filebase64("ansible.sh")
  
  connection {
    type        = "ssh"
    host        = azurerm_linux_virtual_machine.VM.public_ip_address
    user        = azurerm_linux_virtual_machine.VM.admin_username
    private_key = local_file.pem_key.id
  }

  provisioner "file" {
    source = "./ansible.pem"
    destination = "/home/${var.vm_info.admin}/ansible.pem"
  }

  depends_on = [
    azurerm_network_interface.NIC,
    tls_private_key.ssh_key
  ] 

}



  

