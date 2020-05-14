provider "azurerm" {
    subscription_id = ""
    features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "sqlpoc"
  location = "usgovvirginia"
}

resource "azurerm_sql_server" "primary" {
  name                         = "kmack-sql-primary"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "pa$$w0rd"
}

resource "azurerm_sql_server" "secondary" {
  name                         = "kmack-sql-secondary"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = "usgovarizona"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "pa$$w0rd"
}

resource "azurerm_sql_database" "db1" {
  name                = "kmackdb1"
  resource_group_name = azurerm_sql_server.primary.resource_group_name
  location            = azurerm_sql_server.primary.location
  server_name         = azurerm_sql_server.primary.name
}

resource "azurerm_sql_failover_group" "example" {
  name                = "sqlpoc-failover-group"
  resource_group_name = azurerm_sql_server.primary.resource_group_name
  server_name         = azurerm_sql_server.primary.name
  databases           = [azurerm_sql_database.db1.id]
  partner_servers {
    id = azurerm_sql_server.secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}
