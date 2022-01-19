resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "vm_ssh_private_key" {
  filename = "${path.module}/vm.pem"
  content  = tls_private_key.vm.private_key_pem

  file_permission = "0600"
}

resource "azurerm_network_interface" "private_zone_1" {
  for_each = local.regions

  name                = "private-1"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.private[each.value].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.private[each.value].address_prefixes.0, 10)
  }
}

resource "azurerm_network_interface" "private_zone_2" {
  for_each = local.regions

  name                = "private-2"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.private[each.value].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.private[each.value].address_prefixes.0, 11)
  }
}
resource "azurerm_network_interface" "private_zone_3" {
  for_each = local.regions

  name                = "private-3"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.private[each.value].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.private[each.value].address_prefixes.0, 12)
  }
}

/*resource "azurerm_linux_virtual_machine" "private_zone_1" {
  for_each = local.regions

  name                = "${each.key}-1"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location
  zone                = 1
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.private_zone_1[each.value].id,
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

resource "azurerm_linux_virtual_machine" "private_zone_2" {
  for_each = local.regions

  name                = "${each.key}-2"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location
  zone                = 2
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.private_zone_2[each.value].id,
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
resource "azurerm_linux_virtual_machine" "private_zone_3" {
  for_each = local.regions

  name                = "${each.key}-3"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location
  zone                = 1
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.private_zone_3[each.value].id,
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
}*/