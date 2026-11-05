variable "vnet_name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "address_space" { type = list(string) }
variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = { for k, s in azurerm_subnet.subnet : k => s.id }
}