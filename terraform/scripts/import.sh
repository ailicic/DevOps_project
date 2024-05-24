#!/bin/bash

# first command is to import existing resource group, second command is to remove resource group from state file
# one of two needs to be commented when you run script

# import existing resource group
terraform import "azurerm_resource_group.rg-aleksandar-ilicic" "/subscriptions/5fd50c9f-fd1a-41ea-a15b-427dc20b1f20/resourceGroups/rg-aleksandar-ilicic"

#emove resource group from state file
#terraform state rm "azurerm_resource_group.rg-aleksandar-ilicic"

## imported 0

## deleted 1
