variable "environment" {
  description = "Target deployment environment."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "AKS Cluster base name."
  type        = string
  default     = "aks-zero-trust"
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version."
  type        = string
  default     = "1.29.2"
}

variable "node_pools" {
  description = "Map of secondary node pools provisioned dynamically via for_each."
  type = map(object({
    vm_size              = string
    enable_auto_scaling  = bool
    min_count            = number
    max_count            = number
    os_disk_size_gb      = number
    os_disk_type         = string
    node_labels          = map(string)
    node_taints          = optional(list(string), [])
    max_surge            = string
  }))
  default = {
    "userapp" = {
      vm_size             = "Standard_D4s_v5"
      enable_auto_scaling = true
      min_count           = 2
      max_count           = 10
      os_disk_size_gb     = 128
      os_disk_type        = "Ephemeral"
      node_labels = {
        "workload" = "application"
        "tier"     = "zero-trust"
      }
      max_surge = "33%"
    }
    "datasvc" = {
      vm_size             = "Standard_E4s_v5"
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 5
      os_disk_size_gb     = 256
      os_disk_type        = "Managed"
      node_labels = {
        "workload" = "database"
      }
      node_taints = ["dedicated=database:NoSchedule"]
      max_surge   = "25%"
    }
  }
}

variable "enable_azure_keyvault_secrets_provider" {
  description = "Conditional iteration toggle for Key Vault CSI secrets provider."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default = {
    Architecture = "Zero-Trust-Kubernetes-GitOps"
    Security     = "Cilium-eBPF"
    ManagedBy    = "Terraform"
    Owner        = "Rishikesh Sharma"
  }
}
