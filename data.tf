data "azurerm_resource_group" "automation" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}
