resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "bastion_ssh_private_key" {
  filename = "${path.module}/bastion.pem"
  content  = tls_private_key.bastion.private_key_pem

  file_permission = "0600"
}

resource "azurerm_public_ip" "bastion" {
  for_each = local.regions

  name                = "bastion"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = 1

  tags = local.tags
}

resource "azurerm_network_interface" "bastion" {
  for_each = local.regions

  name                = "bastion"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location

  ip_configuration {
    name                          = "bastion"
    subnet_id                     = azurerm_subnet.bastion[each.value].id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.bastion[each.value].address_prefixes.0, 10)
    public_ip_address_id          = azurerm_public_ip.bastion[each.value].id
  }

  tags = local.tags
}

resource "azurerm_network_security_rule" "bastion_ssh" {
  for_each = local.regions

  name                        = "bastion-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_network_interface.bastion[each.value].private_ip_address
  resource_group_name         = azurerm_resource_group.region[each.value].name
  network_security_group_name = azurerm_network_security_group.bastion[each.value].name
}

resource "azurerm_linux_virtual_machine" "bastion" {
  for_each = local.regions

  name                = "bastion-${each.key}-1"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location
  zone                = 1
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.bastion[each.value].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.bastion.public_key_openssh
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