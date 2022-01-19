resource "random_string" "random" {
  length  = 12
  upper   = false
  number  = false
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = "${random_string.random.result}-test"
  location = "eastus2"
  tags     = local.tags
}

resource "azurerm_resource_group" "region" {
  for_each = local.regions

  name     = "${random_string.random.result}-test-${each.value}"
  location = each.value
  tags     = local.tags
}