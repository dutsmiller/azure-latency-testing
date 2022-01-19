data "http" "my_ip" {
  url = "https://ifconfig.me"
}

data "azurerm_subscription" "current" {}