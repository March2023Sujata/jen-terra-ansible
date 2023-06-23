output "ansible-vm-ip" {
  value = format("%s ansible_ssh_private_key_file=/home/${var.vm_info.admin}/ansible.pem ansible_ssh_user=${var.vm_info.admin}", azurerm_linux_virtual_machine.VM.public_ip_address)
}