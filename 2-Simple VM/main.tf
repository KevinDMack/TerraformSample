provider "azurerm" {
  subscription_id = "xxxxxxxxxxxx"
}

resource "azurerm_resource_group" "rg" {
  name     = "SingleVM"
  location = "usgovvirginia"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "singlevm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "usgovvirginia"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_subnet" "vnet-subnet" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  location            = "usgovvirginia"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = "usgovvirginia"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "ssh-access" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}

resource "azurerm_network_interface" "nic" {
  name                      = "vm-nic"
  location                  = "usgovvirginia"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = "${azurerm_subnet.vnet-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }

  tags {
    environment = "Terraform Demo"
  }
}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.rg.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "stgacct" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "usgovvirginia"
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "singlevm"
  location              = "usgovvirginia"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "singlevm_os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "singlevm"
    admin_username = "uadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/uadmin/.ssh/authorized_keys"
      key_data = "{your ssh key here}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.stgacct.primary_blob_endpoint}"
  }

  tags {
    environment = "Terraform Demo"
  }
}
