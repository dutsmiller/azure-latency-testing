resource "azurerm_private_dns_zone" "tld" {
  name                = "test.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "region" {
  for_each = local.regions

  name                  = each.value
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.tld.name
  virtual_network_id    = azurerm_virtual_network.region[each.value].id
}

resource "azurerm_private_dns_a_record" "bastion" {
  for_each = local.regions 

  name                = "bastion.${each.value}"
  zone_name           = azurerm_private_dns_zone.tld.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 60
  records             = [azurerm_network_interface.bastion[each.value].private_ip_address]
}

resource "azurerm_private_dns_a_record" "private_zone_1" {
  for_each = local.regions 

  name                = "zone1.${each.value}"
  zone_name           = azurerm_private_dns_zone.tld.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 60
  records             = [azurerm_network_interface.private_zone_1[each.value].private_ip_address]
}

resource "azurerm_private_dns_a_record" "private_zone_2" {
  for_each = local.regions 

  name                = "zone2.${each.value}"
  zone_name           = azurerm_private_dns_zone.tld.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 60
  records             = [azurerm_network_interface.private_zone_2[each.value].private_ip_address]
}

resource "azurerm_private_dns_a_record" "private_zone_3" {
  for_each = local.regions 

  name                = "zone3.${each.value}"
  zone_name           = azurerm_private_dns_zone.tld.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 60
  records             = [azurerm_network_interface.private_zone_3[each.value].private_ip_address]
}