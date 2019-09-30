provider "azurerm" {
    subscription_id = "7a3a98d5-4b6b-4625-a1e8-3235d432f463"
}
resource "azurerm_resource_group" "rg" {
        name     = "deploy-mack-storage-rg"
        location = "usgovvirginia"
}

resource "azurerm_storage_account" "storage-acct" {
    name = "mackterraformstg"
    resource_group_name      = "${azurerm_resource_group.rg.name}"
    location                 = "${azurerm_resource_group.rg.location}"
    account_replication_type = "GRS"
    account_tier             = "Standard"

    tags = {
        environment = "AzureGovVideo"
    }
}

resource "azurerm_storage_container" "img-container" {
  name = "images"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.storage-acct.name}"
  container_access_type = "private"
}
