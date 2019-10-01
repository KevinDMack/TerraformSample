provider "azurerm" {
    subscription_id = "7a3a98d5-4b6b-4625-a1e8-3235d432f463"
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