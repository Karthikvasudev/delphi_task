variable "client_id" {
	default = "f0720042-c733-4d7f-a84a-803b3b7df068"
}
variable "client_secret" {
	default = "13003584-1682-4634-bab4-f5d68a7f013e"
}

variable "tenant_id" {
    default = "93bb4c86-1f5b-48e6-b8c1-b46d17b15c0a"
}

variable "agent_count" {
    default = 1
}

variable "ssh_public_key" {
    default = "delphi_k8s.pub"
}

variable "dns_prefix" {
    default = "delphik8s"
}

variable cluster_name {
    default = "delphi_k8s"
}

variable resource_group_name {
    default = "rg"
}

variable location {
    default = "Central US"
}

variable log_analytics_workspace_name {
    default = "DelphiLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}