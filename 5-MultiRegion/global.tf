resource "azurerm_resource_group" "availability-global-rg" {
    name = "AvailabilityDemo-global"
    location = "${var.global_region}"

    tags {
        environment = "Demo"
    }
}

resource "azurerm_traffic_manager_profile" "traffic-manager" {
  name                   = "demo-availability-tm"
  resource_group_name    = "${azurerm_resource_group.availability-global-rg.name}"
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "tm-availability-demo"
    ttl           = 300
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }

  tags {
        environment = "Demo"
    }
}

resource "azurerm_traffic_manager_endpoint" "tm-endpoint-primary" {
  name                = "Gateway Primary"
  resource_group_name = "${azurerm_resource_group.availability-global-rg.name}"
  profile_name        = "${azurerm_traffic_manager_profile.traffic-manager.name}"
  type                = "externalEndpoints"
  target              = "${azurerm_public_ip.primary-pip.fqdn}"
  endpoint_location   = "${azurerm_public_ip.primary-pip.location}"

  depends_on = ["azurerm_public_ip.primary-pip","azurerm_application_gateway.primary-appgateway"]

  priority = 1
}

resource "azurerm_traffic_manager_endpoint" "tm-endpoint-secondary" {
  name                = "Gateway Secondary"
  resource_group_name = "${azurerm_resource_group.availability-global-rg.name}"
  profile_name        = "${azurerm_traffic_manager_profile.traffic-manager.name}"
  type                = "externalEndpoints"
  target              = "${azurerm_public_ip.secondary-pip.fqdn}"
  endpoint_location   = "${azurerm_public_ip.secondary-pip.location}"
  
  depends_on = ["azurerm_public_ip.secondary-pip","azurerm_application_gateway.secondary-appgateway"]

  priority = 2
}