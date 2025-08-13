variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create a new resource group or use an existing one"
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "automation_account_name" {
  description = "Name of the Azure Automation Account"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Automation Account"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Free", "Basic"], var.sku_name)
    error_message = "SKU name must be either 'Free' or 'Basic'."
  }
}

variable "runbook_name" {
  description = "Name of the PowerShell runbook"
  type        = string
  default     = "PowerShellRunbook"
}

variable "script_path" {
  description = "Path to the PowerShell script file (script.ps1)"
  type        = string
  default     = "./script.ps1"
}

variable "runbook_description" {
  description = "Description of the runbook"
  type        = string
  default     = "PowerShell runbook deployed via Terraform"
}

variable "log_verbose" {
  description = "Enable verbose logging for the runbook"
  type        = bool
  default     = true
}

variable "log_progress" {
  description = "Enable progress logging for the runbook"
  type        = bool
  default     = true
}

variable "create_schedule" {
  description = "Whether to create a schedule for the runbook"
  type        = bool
  default     = false
}

variable "schedule_name" {
  description = "Name of the schedule"
  type        = string
  default     = "DailySchedule"
}

variable "schedule_frequency" {
  description = "Frequency of the schedule (Hour, Day, Week, Month)"
  type        = string
  default     = "Day"
  validation {
    condition     = contains(["OneTime", "Hour", "Day", "Week", "Month"], var.schedule_frequency)
    error_message = "Schedule frequency must be one of: OneTime, Hour, Day, Week, Month."
  }
}

variable "schedule_interval" {
  description = "Interval for the schedule"
  type        = number
  default     = 1
}

variable "schedule_timezone" {
  description = "Timezone for the schedule"
  type        = string
  default     = "UTC"
}

variable "schedule_start_time" {
  description = "Start time for the schedule (ISO 8601 format)"
  type        = string
  default     = null
}

variable "schedule_description" {
  description = "Description of the schedule"
  type        = string
  default     = "Automated schedule for PowerShell runbook"
}

variable "runbook_parameters" {
  description = "Parameters to pass to the runbook when executed via schedule"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Private network variables
variable "public_network_access_enabled" {
  description = "Enable public network access to the Automation Account"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the Automation Account"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs for the private endpoint"
  type        = list(string)
  default     = []
}

variable "enable_hybrid_worker" {
  description = "Enable hybrid runbook worker group"
  type        = bool
  default     = false
}

variable "hybrid_worker_group_name" {
  description = "Name of the hybrid runbook worker group"
  type        = string
  default     = "HybridWorkerGroup"
}

# Managed Identity variables
variable "identity_type" {
  description = "Type of managed identity (SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "user_assigned_identity_ids" {
  description = "List of existing user-assigned managed identity IDs (used when create_user_assigned_identity is false)"
  type        = list(string)
  default     = []
}

variable "create_user_assigned_identity" {
  description = "Create a new user-assigned managed identity"
  type        = bool
  default     = false
}

variable "user_assigned_identity_name" {
  description = "Name of the user-assigned managed identity to create"
  type        = string
  default     = "automation-identity"
}

variable "existing_user_assigned_identity_principal_id" {
  description = "Principal ID of existing user-assigned identity (for role assignments when not creating new identity)"
  type        = string
  default     = null
}

variable "role_assignments" {
  description = "List of role assignments for the managed identity"
  type = list(object({
    scope = string
    role  = string
  }))
  default = []
}

# Logging and monitoring variables
variable "enable_logging" {
  description = "Enable comprehensive logging with Log Analytics"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace to create"
  type        = string
  default     = "law-automation"
}

variable "existing_log_analytics_workspace_id" {
  description = "ID of existing Log Analytics workspace (used when enable_logging is false)"
  type        = string
  default     = null
}

variable "log_analytics_sku" {
  description = "SKU for the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "PerNode", "PerGB2018", "Standalone", "Standard", "Premium"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, PerNode, PerGB2018, Standalone, Standard, Premium."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention must be between 30 and 730 days."
  }
}

variable "log_categories" {
  description = "List of log categories to enable"
  type        = list(string)
  default = [
    "JobLogs",
    "JobStreams", 
    "DscNodeStatus",
    "AuditEvent"
  ]
}