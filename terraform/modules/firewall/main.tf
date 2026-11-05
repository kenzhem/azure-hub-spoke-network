variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "hub_subnet_id" { type = string }
variable "spoke_subnet_ids" { type = map(string) }

resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-azfw-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub_fw" {
  name                = "afw-central-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.hub_subnet_id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

resource "azurerm_route_table" "spoke_rt" {
  name                          = "rt-spoke-to-firewall"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name                   = "DefaultRouteToFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "assoc" {
  for_each       = var.spoke_subnet_ids
  subnet_id      = each.value
  route_table_id = azurerm_route_table.spoke_rt.id
}

output "firewall_private_ip" {
  value = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
}