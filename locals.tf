locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.automation[0].name : data.azurerm_resource_group.automation[0].name
  user_assigned_identity_ids = var.create_user_assigned_identity ? [azurerm_user_assigned_identity.main[0].id] : var.user_assigned_identity_ids
}
