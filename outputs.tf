output "automation_account_id" {
  description = "ID of the created Automation Account"
  value       = azurerm_automation_account.main.id
}

output "automation_account_name" {
  description = "Name of the created Automation Account"
  value       = azurerm_automation_account.main.name
}

output "automation_account_identity" {
  description = "Managed identity details of the Automation Account"
  value = var.identity_type != null ? {
    type         = azurerm_automation_account.main.identity[0].type
    principal_id = azurerm_automation_account.main.identity[0].principal_id
    tenant_id    = azurerm_automation_account.main.identity[0].tenant_id
    identity_ids = azurerm_automation_account.main.identity[0].identity_ids
  } : null
}

output "runbook_id" {
  description = "ID of the created runbook"
  value       = azurerm_automation_runbook.powershell_script.id
}

output "runbook_name" {
  description = "Name of the created runbook"
  value       = azurerm_automation_runbook.powershell_script.name
}

output "resource_group_name" {
  description = "Name of the resource group used"
  value       = local.resource_group_name
}

output "schedule_id" {
  description = "ID of the created schedule (if created)"
  value       = var.create_schedule ? azurerm_automation_schedule.main[0].id : null
}

output "schedule_name" {
  description = "Name of the created schedule (if created)"
  value       = var.create_schedule ? azurerm_automation_schedule.main[0].name : null
}

output "user_assigned_identity" {
  description = "Details of the created user-assigned managed identity (if created)"
  value = var.create_user_assigned_identity ? {
    id           = azurerm_user_assigned_identity.main[0].id
    name         = azurerm_user_assigned_identity.main[0].name
    principal_id = azurerm_user_assigned_identity.main[0].principal_id
    client_id    = azurerm_user_assigned_identity.main[0].client_id
    tenant_id    = azurerm_user_assigned_identity.main[0].tenant_id
  } : null
}

output "role_assignments" {
  description = "List of role assignments created for the managed identity"
  value = {
    for k, v in azurerm_role_assignment.identity_assignments : k => {
      scope = v.scope
      role  = v.role_definition_name
    }
  }
}

output "log_analytics_workspace" {
  description = "Details of the Log Analytics workspace (if created)"
  value = var.enable_logging ? {
    id                = azurerm_log_analytics_workspace.main[0].id
    name              = azurerm_log_analytics_workspace.main[0].name
    workspace_id      = azurerm_log_analytics_workspace.main[0].workspace_id
    primary_shared_key = azurerm_log_analytics_workspace.main[0].primary_shared_key
  } : null
  sensitive = true
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting (if logging enabled)"
  value       = var.enable_logging ? azurerm_monitor_diagnostic_setting.automation_account[0].id : null
}