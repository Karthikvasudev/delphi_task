variable "client_id" {
	default = "Replace your id here"
}
variable "client_secret" {
	default = "Replace the secret here"
}

variable "tenant_id" {
    default = "Replace your id here"
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
