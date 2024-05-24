resource "azurerm_resource_group" "rg-aleksandar-ilicic" {
  location = "northeurope"
  name     = "rg-aleksandar-ilicic"
}


resource "azurerm_virtual_network" "vnet" {

    name                = "vnet-aleksandar-ilicic"
    address_space       = ["10.0.0.1/24"]
    location            = azurerm_resource_group.rg-aleksandar-ilicic.location
    resource_group_name = azurerm_resource_group.rg-aleksandar-ilicic.name

}