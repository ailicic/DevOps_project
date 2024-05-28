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

resource "azurerm_virtual_machine" "test" {
    name                  = "test"
    resource_group_name   = azurerm_resource_group.rg-aleksandar-ilicic.name
    location              = azurerm_resource_group.rg-aleksandar-ilicic.location
    network_interface_ids = [azurerm_network_interface.nic.id]

    storage_os_disk {
        name              = "osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "test"
        admin_username = "adminuser"
        admin_password = "password"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

 

    vm_size = "Standard_DS1_v2" # Add the missing "vm_size" attribute

    tags = {
        environment = "dev"
    }
}