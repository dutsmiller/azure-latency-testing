resource "azurerm_virtual_network" "region" {
  for_each = local.regions

  name                = "vnet"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location
  tags                = local.tags

  address_space = [local.azure_regions[each.value].cidr]
}

resource "azurerm_subnet" "bastion" {
  for_each = local.regions

  depends_on = [azurerm_virtual_network.region]

  name                 = "bastion"
  resource_group_name  = azurerm_resource_group.region[each.value].name
  virtual_network_name = azurerm_virtual_network.region[each.value].name
  address_prefixes     = [cidrsubnet(local.azure_regions[each.value].cidr, 1, 0)]
}

resource "azurerm_subnet" "private" {
  for_each = local.regions

  depends_on = [azurerm_virtual_network.region]

  name                 = "private"
  resource_group_name  = azurerm_resource_group.region[each.value].name
  virtual_network_name = azurerm_virtual_network.region[each.value].name
  address_prefixes     = [cidrsubnet(local.azure_regions[each.value].cidr, 1, 1)]
}

resource "azurerm_network_security_group" "private" {
  for_each = local.regions

  name                = "private"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "private" {
  for_each = local.regions

  depends_on = [azurerm_subnet.private]

  subnet_id                 = azurerm_subnet.private[each.value].id
  network_security_group_id = azurerm_network_security_group.private[each.value].id
}

resource "azurerm_network_security_group" "bastion" {
  for_each = local.regions

  name                = "bastion"
  resource_group_name = azurerm_resource_group.region[each.value].name
  location            = azurerm_resource_group.region[each.value].location
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  for_each = local.regions

  depends_on = [azurerm_subnet.bastion]

  subnet_id                 = azurerm_subnet.bastion[each.value].id
  network_security_group_id = azurerm_network_security_group.bastion[each.value].id
}

resource "azurerm_virtual_network_peering" "vnet" {
  for_each = local.peer_map

  depends_on = [azurerm_virtual_network.region]

  name                      = each.key
  resource_group_name       = azurerm_resource_group.region[each.value.local].name
  virtual_network_name      = azurerm_virtual_network.region[each.value.local].name
  remote_virtual_network_id = azurerm_virtual_network.region[each.value.remote].id
}