provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
}
resource "azurerm_resource_group" "rg" {
        name = "DelphiRG"
        location = var.location
}
resource "azurerm_virtual_network" "delphi_task_vnet" {
  name                = "delphi_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet_pub" {
  name                 = "delphi-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.delphi_task_vnet.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "EIP" {
  name                = "nat-gateway-publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_public_ip_prefix" "EIP_prefix" {
  name                = "nat-gateway-publicIPPrefix"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  prefix_length       = 30
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "delphi_nat" {
  name                    = "deplhi-nat"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  public_ip_address_ids   = [azurerm_public_ip.EIP.id]
  public_ip_prefix_ids    = [azurerm_public_ip_prefix.EIP_prefix.id]
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_subnet_nat_gateway_association" "nat_associate" {
  subnet_id      = azurerm_subnet.subnet_pub.id
  nat_gateway_id = azurerm_nat_gateway.delphi_nat.id
}

#Creates Azure K8s service and ACR with admin

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "delphi_task_la" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "deplhi_sol" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.delphi_task_la.location
    resource_group_name   = azurerm_resource_group.rg.name
    workspace_resource_id = azurerm_log_analytics_workspace.delphi_task_la.id
    workspace_name        = azurerm_log_analytics_workspace.delphi_task_la.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "delphi_k8s" {
    name                = var.cluster_name
    location            = "westus"
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix          = var.dns_prefix

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_D2"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.delphi_task_la.id
        }
    }

    tags = {
        Environment = "Task"
    }
}

resource "azurerm_container_registry" "delphi_acr" {
  name                     = "delphiacr"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = true
  network_rule_set         = []
}

#Creates Azure key_vault

data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "delphi_vault" {
  name                        = "delphivault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
      "list",
    ]

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete",
    ]

    storage_permissions = [
      "get",
      "list",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass = "AzureServices"
  }

  tags = {
    environment = "Task"
  }
}

resource "azurerm_key_vault_secret" "delphi_secret" {
  name         = "UserName"
  value        = azurerm_container_registry.delphi_acr.admin_username
  key_vault_id = azurerm_key_vault.delphi_vault.id

  tags = {
    environment = "Task"
  }
}

resource "azurerm_key_vault_secret" "delphi_secret1" {
  name         = "Password"
  value        = azurerm_container_registry.delphi_acr.admin_password
  key_vault_id = azurerm_key_vault.delphi_vault.id

  tags = {
    environment = "Task"
  }
}

resource "azurerm_key_vault_secret" "delphi_secret2" {
  name         = "clientid"
  value        = var.client_id
  key_vault_id = azurerm_key_vault.delphi_vault.id

  tags = {
    environment = "Task"
  }
}

resource "azurerm_key_vault_secret" "delphi_secret3" {
  name         = "clientsecret"
  value        = var.client_secret
  key_vault_id = azurerm_key_vault.delphi_vault.id

  tags = {
    environment = "Task"
  }
}

resource "azurerm_key_vault_secret" "delphi_secret4" {
  name         = "tenantid"
  value        = var.tenant_id
  key_vault_id = azurerm_key_vault.delphi_vault.id

  tags = {
    environment = "Task"
  }
}

resource "azurerm_key_vault_secret" "delphi_k8s_fqdn" {
  name         = "k8sfqdn"
  value        = azurerm_kubernetes_cluster.delphi_k8s.fqdn
  key_vault_id = azurerm_key_vault.delphi_vault.id

  tags = {
    environment = "Task"
  }
}
#Output section
output "login_server" {
  value = azurerm_container_registry.delphi_acr.login_server
}
output "admin_username" {
  value = azurerm_container_registry.delphi_acr.admin_username
}
output "admin_password" {
  value = azurerm_container_registry.delphi_acr.admin_password
}
output "vault_uri" {
  value = azurerm_key_vault.delphi_vault.vault_uri
}

