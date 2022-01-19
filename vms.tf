resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "vm_ssh_private_key" {
  filename = "${path.module}/vm.pem"
  content  = tls_private_key.vm.private_key_pem

  file_permission = "0600"
}

resource "azurerm_network_interface" "private" {
  for_each = local.vms

  depends_on = [azurerm_subnet.private]

  name                = "private-${each.value.zone}"
  resource_group_name = azurerm_resource_group.region[each.value.region].name
  location            = azurerm_resource_group.region[each.value.region].location

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.private[each.value.region].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.private[each.value.region].address_prefixes.0, (10 + "${each.value.zone}"))
  }
}

resource "azurerm_linux_virtual_machine" "private" {
  for_each = local.vms

  name                = "${each.value.zone}-1"
  resource_group_name = azurerm_resource_group.region[each.value.region].name
  location            = azurerm_resource_group.region[each.value.region].location
  zone                = 1
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.private[each.key].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.vm.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  tags = local.tags
}