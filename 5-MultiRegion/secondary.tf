resource "azurerm_resource_group" "availability-secondary-rg" {
    name = "AvailabilityDemo-secondary"
    location = "${var.secondary_region}"
}

resource "azurerm_virtual_network" "secondary-vnet" {
    name = "secondary-vnet"
    location = "${azurerm_resource_group.availability-secondary-rg.location}"
    resource_group_name = "${azurerm_resource_group.availability-secondary-rg.name}"
    address_space = ["10.0.0.0/16"]   
}

resource "azurerm_subnet" "secondary-subnet" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.availability-secondary-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.secondary-vnet.name}"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_public_ip" "secondary-pip" {
  name                         = "secondary-appgateway-pip"
  location                     = "${azurerm_resource_group.availability-secondary-rg.location}"
  resource_group_name          = "${azurerm_resource_group.availability-secondary-rg.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "kmack-secondarysite"
}

resource "azurerm_application_gateway" "secondary-appgateway" {
  name                = "secondary-appgateway"
  resource_group_name = "${azurerm_resource_group.availability-secondary-rg.name}"
  location            = "${azurerm_resource_group.availability-secondary-rg.location}"

  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 2
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "subnet"
    subnet_id = "${azurerm_virtual_network.secondary-vnet.id}/subnets/${azurerm_subnet.secondary-subnet.name}"
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = "${azurerm_public_ip.secondary-pip.id}"
  }

  backend_address_pool {
    name        = "AppService"
    fqdn_list = ["${azurerm_app_service.secondary-as.name}.azurewebsites.us"]
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  probe {
    name                = "probe"
    protocol            = "http"
    path                = "/"
    host                = "${azurerm_app_service.secondary-as.name}.azurewebsites.us"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  backend_http_settings {
    name                  = "http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "probe"
    pick_host_name_from_backend_address = "true"
  }

  request_routing_rule {
    name                       = "http"
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = "AppService"
    backend_http_settings_name = "http"
  }

}

resource "azurerm_app_service_plan" "secondary-asp" {
  name                = "secondary-web-asp"
  location            = "${var.secondary_region}"
  resource_group_name = "${azurerm_resource_group.availability-secondary-rg.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }

}

resource "azurerm_app_service" "secondary-as" {
  name                = "secondary-web-as"
  location            = "${azurerm_resource_group.availability-secondary-rg.location}"
  resource_group_name = "${azurerm_resource_group.availability-secondary-rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.secondary-asp.id}"

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = ""
  }

}

