# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "nodejs_rg" {
  name     = "nodejs-app-rg"
  location = "eastus" # Free tier regions may vary
}

# Virtual network
resource "azurerm_virtual_network" "nodejs_vnet" {
  name                = "nodejs-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.nodejs_rg.location
  resource_group_name = azurerm_resource_group.nodejs_rg.name
}

# Subnet
resource "azurerm_subnet" "nodejs_subnet" {
  name                 = "nodejs-subnet"
  resource_group_name  = azurerm_resource_group.nodejs_rg.name
  virtual_network_name = azurerm_virtual_network.nodejs_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "nodejs_public_ip" {
  name                = "nodejs-public-ip"
  location            = azurerm_resource_group.nodejs_rg.location
  resource_group_name = azurerm_resource_group.nodejs_rg.name
  allocation_method   = "Dynamic"
}

# Network Security Group
resource "azurerm_network_security_group" "nodejs_nsg" {
  name                = "nodejs-nsg"
  location            = azurerm_resource_group.nodejs_rg.location
  resource_group_name = azurerm_resource_group.nodejs_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "nodejs_nic" {
  name                = "nodejs-nic"
  location            = azurerm_resource_group.nodejs_rg.location
  resource_group_name = azurerm_resource_group.nodejs_rg.name

  ip_configuration {
    name                          = "nodejs-nic-config"
    subnet_id                     = azurerm_subnet.nodejs_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nodejs_public_ip.id
  }
}

# Connect NSG to Network Interface
resource "azurerm_network_interface_security_group_association" "nodejs_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nodejs_nic.id
  network_security_group_id = azurerm_network_security_group.nodejs_nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "nodejs_vm" {
  name                  = "nodejs-vm"
  location              = azurerm_resource_group.nodejs_rg.location
  resource_group_name   = azurerm_resource_group.nodejs_rg.name
  network_interface_ids = [azurerm_network_interface.nodejs_nic.id]
  size                  = "Standard_F1" # Free tier VM size

  os_disk {
    name                 = "nodejs-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name                   = "nodejsvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub") # Ensure you have an SSH key
  }
}
