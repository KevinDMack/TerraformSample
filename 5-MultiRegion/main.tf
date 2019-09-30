provider "azurerm" {
    subscription_id = ""
}

variable "primary_region" {
    description = "Primary Region to be deployed to"
}

variable "secondary_region" {
    description = "Secondary Region to be deployed to"
}

variable "global_region" {
    description = "region for global resources"
}