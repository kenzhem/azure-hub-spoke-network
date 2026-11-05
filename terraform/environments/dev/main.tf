terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
  }
  # Удаленный бэкенд для защиты стейта (Remote State Backend)
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstateenterprise01"
    container_name       = "tfstate"
    key                  = "network-dev.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-enterprise-network-dev"
  location = "eastus"
}

# Hub VNet (Центральная сеть)
module "hub_vnet" {
  source              = "../../modules/vnet"
  vnet_name           = "vnet-hub-eastus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  subnets = {
    AzureFirewallSubnet = { address_prefix = "10.0.1.0/26" },
    AzureBastionSubnet  = { address_prefix = "10.0.2.0/26" }
  }
}

# Spoke VNet (Рабочая нагрузка / Приложение)
module "spoke_prod" {
  source              = "../../modules/vnet"
  vnet_name           = "vnet-spoke-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/16"]
  subnets = {
    AppSubnet = { address_prefix = "10.1.1.0/24" },
    DBSubnet  = { address_prefix = "10.1.2.0/24" }
  }
}

# Централизованный Фаервол и маршрутизация
module "hub_firewall" {
  source              = "../../modules/firewall"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  hub_subnet_id       = module.hub_vnet.subnet_ids["AzureFirewallSubnet"]
  spoke_subnet_ids    = { for k, id in module.spoke_prod.subnet_ids : k => id }
}

# Пиринг между Hub и Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke-prod"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = "vnet-hub-eastus"
  remote_virtual_network_id = module.spoke_prod.vnet_id
  allow_forwarded_traffic   = true
  depends_on                = [module.hub_vnet, module.spoke_prod]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-prod-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = "vnet-spoke-prod"
  remote_virtual_network_id = module.hub_vnet.vnet_id
  allow_forwarded_traffic   = true
  depends_on                = [module.hub_vnet, module.spoke_prod]
}