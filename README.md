# Azure Automation Terraform Module

This comprehensive Terraform module creates a secure Azure Automation Account with PowerShell runbooks, managed identities, private networking capabilities, and comprehensive logging for enterprise-grade automation workflows.

## Features

### Core Automation
- **Azure Automation Account** with configurable SKU (Free/Basic)
- **PowerShell Runbook** deployment from your custom script.ps1 file
- **Flexible Scheduling** for automated execution with timezone support
- **Parameter Management** for runbook inputs

### Security & Identity
- **Managed Identity Support**:
  - System-assigned (default)
  - User-assigned (create new or use existing)
  - Combined system + user-assigned
- **Role-Based Access Control** with configurable permissions
- **Private Network Integration**:
  - Private endpoints for secure connectivity
  - Hybrid runbook workers for on-premises execution
  - Public network access controls

### Monitoring & Logging
- **Log Analytics Integration** with automatic workspace creation
- **Comprehensive Diagnostic Settings** capturing:
  - Job execution logs and streams
  - Security audit events
  - DSC node status
  - Performance metrics
- **Configurable Log Retention** (30-730 days)
- **Security Monitoring** for compliance and auditing

### Infrastructure Management
- **Resource Group Management** (create new or use existing)
- **Flexible Networking** with VNet integration
- **Tagging Support** for governance and cost management

## Usage Examples

### Basic Secure Setup
```hcl
module "azure_automation" {
  source = "./aa-terraform"
  
  resource_group_name     = "rg-automation"
  automation_account_name = "aa-secure"
  script_path            = "./my-script.ps1"
  
  # Security: Disable public access
  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = "/subscriptions/.../subnets/automation-subnet"
  
  # Logging enabled by default
  log_retention_days = 90
  
  tags = {
    Environment = "Production"
    Purpose     = "SecureAutomation"
  }
}
```

### User-Assigned Identity with Permissions
```hcl
module "azure_automation" {
  source = "./aa-terraform"
  
  automation_account_name = "aa-identity"
  resource_group_name     = "rg-automation"
  
  # Create user-assigned identity
  create_user_assigned_identity = true
  user_assigned_identity_name   = "automation-identity"
  identity_type                 = "UserAssigned"
  
  # Configure least-privilege permissions
  role_assignments = [
    {
      scope = "/subscriptions/xxx/resourceGroups/rg-storage"
      role  = "Storage Blob Data Reader"
    },
    {
      scope = "/subscriptions/xxx/resourceGroups/rg-keyvault/providers/Microsoft.KeyVault/vaults/kv-secrets"
      role  = "Key Vault Secrets User"
    }
  ]
}
```

### Scheduled Execution with Hybrid Workers
```hcl
module "azure_automation" {
  source = "./aa-terraform"
  
  automation_account_name = "aa-scheduled"
  resource_group_name     = "rg-automation"
  script_path            = "./maintenance-script.ps1"
  
  # Schedule configuration
  create_schedule      = true
  schedule_name        = "WeeklyMaintenance"
  schedule_frequency   = "Week"
  schedule_interval    = 1
  schedule_start_time  = "2024-01-07T02:00:00Z"
  schedule_timezone    = "UTC"
  
  # Hybrid worker for on-premises access
  enable_hybrid_worker      = true
  hybrid_worker_group_name = "OnPremWorkers"
  
  runbook_parameters = {
    MaintenanceType = "Full"
    NotifyEmail     = "admin@company.com"
  }
}
```

### Private Network with Existing Log Analytics
```hcl
module "azure_automation" {
  source = "./aa-terraform"
  
  automation_account_name = "aa-private"
  resource_group_name     = "rg-automation"
  
  # Private networking
  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = "/subscriptions/.../subnets/automation-subnet"
  private_dns_zone_ids         = ["/subscriptions/.../privateDnsZones/privatelink.azure-automation.net"]
  
  # Use existing Log Analytics
  enable_logging                     = false
  existing_log_analytics_workspace_id = "/subscriptions/.../workspaces/law-central"
}
```

## Security Best Practices

### Network Security
- Disable public access: `public_network_access_enabled = false`
- Use private endpoints for VNet integration
- Configure private DNS zones for name resolution

### Identity & Access Management
- Use user-assigned identities for shared resources
- Apply least-privilege permissions via `role_assignments`
- Monitor identity usage through audit logs

### Logging & Monitoring
- Enable comprehensive logging (default: enabled)
- Set appropriate retention periods for compliance
- Monitor job execution and security events

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| azurerm | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |

## Authentication

Configure authentication using Azure CLI:
```bash
az login
az account set --subscription "your-subscription-id"
```

## Inputs

### Core Configuration
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| automation_account_name | Name of the Azure Automation Account | `string` | n/a | yes |
| script_path | Path to the PowerShell script file | `string` | `"./script.ps1"` | no |
| create_resource_group | Whether to create a new resource group | `bool` | `true` | no |
| location | Azure region where resources will be created | `string` | `"East US"` | no |
| sku_name | SKU name for the Automation Account (Free/Basic) | `string` | `"Basic"` | no |

### Runbook Configuration
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| runbook_name | Name of the PowerShell runbook | `string` | `"PowerShellRunbook"` | no |
| runbook_description | Description of the runbook | `string` | `"PowerShell runbook deployed via Terraform"` | no |
| log_verbose | Enable verbose logging for the runbook | `bool` | `true` | no |
| log_progress | Enable progress logging for the runbook | `bool` | `true` | no |

### Scheduling
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_schedule | Whether to create a schedule for the runbook | `bool` | `false` | no |
| schedule_frequency | Frequency of the schedule (OneTime/Hour/Day/Week/Month) | `string` | `"Day"` | no |
| schedule_interval | Interval for the schedule | `number` | `1` | no |
| schedule_timezone | Timezone for the schedule | `string` | `"UTC"` | no |
| runbook_parameters | Parameters to pass to the runbook | `map(string)` | `{}` | no |

### Security & Networking
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| public_network_access_enabled | Enable public network access | `bool` | `true` | no |
| enable_private_endpoint | Enable private endpoint | `bool` | `false` | no |
| private_endpoint_subnet_id | Subnet ID for the private endpoint | `string` | `null` | no |
| private_dns_zone_ids | List of private DNS zone IDs | `list(string)` | `[]` | no |

### Managed Identity
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identity_type | Type of managed identity | `string` | `"SystemAssigned"` | no |
| create_user_assigned_identity | Create a new user-assigned identity | `bool` | `false` | no |
| user_assigned_identity_name | Name of the user-assigned identity | `string` | `"automation-identity"` | no |
| role_assignments | List of role assignments for the identity | `list(object)` | `[]` | no |

### Logging & Monitoring
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_logging | Enable Log Analytics logging | `bool` | `true` | no |
| log_analytics_workspace_name | Name of the Log Analytics workspace | `string` | `"law-automation"` | no |
| log_retention_days | Number of days to retain logs (30-730) | `number` | `30` | no |
| log_categories | List of log categories to enable | `list(string)` | `["JobLogs", "JobStreams", "DscNodeStatus", "AuditEvent"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| automation_account_id | ID of the created Automation Account |
| automation_account_name | Name of the created Automation Account |
| automation_account_identity | Managed identity details of the Automation Account |
| runbook_id | ID of the created runbook |
| runbook_name | Name of the created runbook |
| user_assigned_identity | Details of the created user-assigned identity (if created) |
| role_assignments | List of role assignments created for the managed identity |
| log_analytics_workspace | Details of the Log Analytics workspace (if created) |
| diagnostic_setting_id | ID of the diagnostic setting (if logging enabled) |

## PowerShell Script Requirements

Your `script.ps1` file should follow these guidelines:

```powershell
param(
    [Parameter(Mandatory=$false)]
    [string]$ExampleParameter = "DefaultValue"
)

# Use managed identity for authentication
Connect-AzAccount -Identity

Write-Output "Starting script execution..."

try {
    # Your automation logic here
    $result = Get-AzVM
    Write-Output "Found $($result.Count) virtual machines"
    
    # Use Write-Output for logging (captured in Log Analytics)
    Write-Output "Script completed successfully"
}
catch {
    # Proper error handling
    Write-Error "Error: $($_.Exception.Message)"
    throw
}
finally {
    # Cleanup if needed
    Write-Output "Script execution finished"
}
```

## Security Considerations

1. **Network Access**: Disable public access for production workloads
2. **Identity Permissions**: Use least-privilege principle for role assignments
3. **Logging**: Enable comprehensive logging for security monitoring
4. **Script Security**: Validate inputs and avoid hardcoded secrets
5. **Private Endpoints**: Use for secure VNet connectivity

## Monitoring and Troubleshooting

### Log Analytics Queries
```kusto
// Recent job executions
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.AUTOMATION"
| where Category == "JobLogs"
| order by TimeGenerated desc

// Failed jobs
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.AUTOMATION"
| where Category == "JobStreams"
| where ResultDescription contains "Failed"
```

### Manual Execution
1. Navigate to Azure Portal → Automation Account
2. Go to "Runbooks" under "Process Automation"  
3. Select your runbook and click "Start"
4. Provide required parameters
5. Monitor execution in "Jobs" section

## License

This module is provided as-is for educational and production use. Ensure compliance with your organization's security policies before deployment.