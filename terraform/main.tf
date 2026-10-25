resource "azurerm_resource_group" "aks_rg" {
  name     = "rg-${var.cluster_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# 1. Zero-Trust AKS Cluster with Azure CNI powered by Cilium
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.cluster_name}-${var.environment}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.cluster_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    node_count          = 2
    vm_size             = "Standard_D2s_v5"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
    os_disk_size_gb     = 64
    only_critical_addons_enabled = true
    tags                = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    ebpf_data_path      = "cilium"
    load_balancer_sku   = "standard"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = var.enable_azure_keyvault_secrets_provider
    secret_rotation_interval = "2m"
  }

  tags = var.tags
}

# 2. Secondary Node Pools Iterated via for_each with dynamic upgrade_settings
resource "azurerm_kubernetes_cluster_node_pool" "pools" {
  for_each = var.node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  node_labels           = each.value.node_labels
  node_taints           = lookup(each.value, "node_taints", [])

  dynamic "upgrade_settings" {
    for_each = [each.value.max_surge]
    content {
      max_surge = upgrade_settings.value
    }
  }

  tags = var.tags
}
