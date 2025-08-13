# Provider configuration moved to provider.tf

resource "azurerm_resource_group" "automation" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

data "azurerm_resource_group" "automation" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.automation[0].name : data.azurerm_resource_group.automation[0].name
  user_assigned_identity_ids = var.create_user_assigned_identity ? [azurerm_user_assigned_identity.main[0].id] : var.user_assigned_identity_ids
}

resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enable_logging ? 1 : 0
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "main" {
  count               = var.create_user_assigned_identity ? 1 : 0
  name                = var.user_assigned_identity_name
  location            = var.location
  resource_group_name = local.resource_group_name

  tags = var.tags
}

resource "azurerm_automation_account" "main" {
  name                          = var.automation_account_name
  location                      = var.location
  resource_group_name           = local.resource_group_name
  sku_name                      = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? local.user_assigned_identity_ids : null
    }
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "main" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.automation_account_name}-pe"
  location            = var.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.automation_account_name}-psc"
    private_connection_resource_id = azurerm_automation_account.main.id
    subresource_names              = ["DSCAndHybridWorker"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "automation-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

resource "azurerm_automation_hybrid_runbook_worker_group" "main" {
  count                   = var.enable_hybrid_worker ? 1 : 0
  name                    = var.hybrid_worker_group_name
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
}

# Role assignments for the managed identity
resource "azurerm_role_assignment" "identity_assignments" {
  for_each = {
    for assignment in var.role_assignments : "${assignment.scope}-${assignment.role}" => assignment
  }

  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id = var.create_user_assigned_identity ? azurerm_user_assigned_identity.main[0].principal_id : (
    var.identity_type == "SystemAssigned" ? azurerm_automation_account.main.identity[0].principal_id : 
    var.existing_user_assigned_identity_principal_id
  )

  depends_on = [
    azurerm_automation_account.main,
    azurerm_user_assigned_identity.main
  ]
}

resource "azurerm_automation_runbook" "powershell_script" {
  name                    = var.runbook_name
  location                = var.location
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  log_verbose             = var.log_verbose
  log_progress            = var.log_progress
  description             = var.runbook_description
  runbook_type            = "PowerShell"

  content = file(var.script_path)

  tags = var.tags
}

resource "azurerm_automation_schedule" "main" {
  count                   = var.create_schedule ? 1 : 0
  name                    = var.schedule_name
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  frequency               = var.schedule_frequency
  interval                = var.schedule_interval
  timezone                = var.schedule_timezone
  start_time              = var.schedule_start_time
  description             = var.schedule_description

  depends_on = [azurerm_automation_runbook.powershell_script]
}

resource "azurerm_automation_job_schedule" "main" {
  count                   = var.create_schedule ? 1 : 0
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  schedule_name           = azurerm_automation_schedule.main[0].name
  runbook_name            = azurerm_automation_runbook.powershell_script.name

  parameters = var.runbook_parameters

  depends_on = [
    azurerm_automation_runbook.powershell_script,
    azurerm_automation_schedule.main
  ]
}

# Diagnostic settings for comprehensive logging
resource "azurerm_monitor_diagnostic_setting" "automation_account" {
  count                      = var.enable_logging ? 1 : 0
  name                       = "${var.automation_account_name}-diagnostics"
  target_resource_id         = azurerm_automation_account.main.id
  log_analytics_workspace_id = var.enable_logging ? azurerm_log_analytics_workspace.main[0].id : var.existing_log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.log_categories
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    azurerm_automation_account.main,
    azurerm_log_analytics_workspace.main
  ]
}