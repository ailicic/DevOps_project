resource "azurerm_resource_group" "rg-aleksandar-ilicic" {
  location = "northeurope"
  name     = "rg-aleksandar-ilicic2"
}

resource "azurerm_virtual_network" "vnetk8s" {
  name                = "vnetk8s"
  resource_group_name = azurerm_resource_group.rg-aleksandar-ilicic.name
  location            = azurerm_resource_group.rg-aleksandar-ilicic.location
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]


}

resource "azurerm_subnet" "gwSubnet" {
  name                 = "gwSubnet"
  resource_group_name  = azurerm_resource_group.rg-aleksandar-ilicic.name
  virtual_network_name = azurerm_virtual_network.vnetk8s.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [
    azurerm_virtual_network.vnetk8s
  ]
}

# resource "azurerm_subnet" "aks_subnet" {
#   name                 = "aks_subnet"
#   resource_group_name  = azurerm_resource_group.rg-aleksandar-ilicic.name
#   virtual_network_name = azurerm_virtual_network.vnetk8s.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_subnet" "app_gw_subnet" {
#     name = "app_gw_subnet"
#     resource_group_name = azurerm_resource_group.rg-aleksandar-ilicic.name
#     virtual_network_name = azurerm_virtual_network.vnetk8s.name
#     address_prefixes = ["10.0.2.0/24"]

#     delegation {
#     name = "appgwdelegation"

#     service_delegation {
#       name    = "Microsoft.Web/applicationGateways"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
#     }
#   }
# }



resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "k8s"
  location            = azurerm_resource_group.rg-aleksandar-ilicic.location
  resource_group_name = azurerm_resource_group.rg-aleksandar-ilicic.name
  dns_prefix          = "k8s"

  identity {
    type = "SystemAssigned"
  }

  

  sku_tier = "Free"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_b2ms"
    node_count = 2
  }

  network_profile {
    # network_plugin = "kubenet"
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.0.3.0/24"
    dns_service_ip    = "10.0.3.10"
  }

  depends_on = [
    azurerm_virtual_network.vnetk8s
  ]

}

// static IP for load balancer
resource "azurerm_public_ip" "staticIP" {
  name                = "static_ip"
  location            = azurerm_resource_group.rg-aleksandar-ilicic.location
  resource_group_name = "MC_rg-aleksandar-ilicic2_k8s_northeurope"
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]

}

// static IP for application gateway
resource "azurerm_public_ip" "staticIP2" {
  name                = "static_ip2"
  location            = azurerm_resource_group.rg-aleksandar-ilicic.location
  resource_group_name = azurerm_resource_group.rg-aleksandar-ilicic.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  depends_on = [
    azurerm_virtual_network.vnetk8s
  ]

}

# resource "kubernetes_deployment" "nginx-deployment" {
#   metadata {
#     name = "nginx"
#   }
#   spec {
#     replicas = 1
#     selector {
#       match_labels = {
#         app = "nginx"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = "nginx"
#         }
#       }
#       spec {
#         container {
#           image = "nginx:latest"
#           name  = "nginx"
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }

#   }
# }

# resource "kubernetes_service" "svc-lb" {
#   metadata {
#     name = "nginx-service"
#   }
#   spec {
#     type             = "LoadBalancer"
#     load_balancer_ip = azurerm_public_ip.staticIP.ip_address
#     selector = {
#       app = "nginx"
#     }
#     port {
#       protocol    = "TCP"
#       port        = 80
#       target_port = 80
#     }
#   }
# }

resource "azurerm_application_gateway" "appGateway" {
  name                = "appGateway"
  resource_group_name = azurerm_resource_group.rg-aleksandar-ilicic.name
  location            = azurerm_resource_group.rg-aleksandar-ilicic.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.gwSubnet.id
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = azurerm_public_ip.staticIP2.id
  }

  backend_address_pool {
    name         = "BackendPool"
    ip_addresses = [azurerm_public_ip.staticIP.ip_address]


  }








  backend_http_settings {
    name = "backendSetting1"
    #path = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    cookie_based_affinity = "Disabled"
  }

  http_listener {
    name                           = "listener1"
    protocol                       = "Http"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_80"
  }

  request_routing_rule {
    name                       = "rule1"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "listener1"
    backend_address_pool_name  = "BackendPool"
    backend_http_settings_name = "backendSetting1"

  }

  depends_on = [
    azurerm_virtual_network.vnetk8s
  ]

}