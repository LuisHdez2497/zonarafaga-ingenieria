# Quién leyó qué secreto y cuándo. Sin esto, la bóveda guarda pero no cuenta.
resource "azurerm_monitor_diagnostic_setting" "boveda" {
  name                       = "auditoria"
  target_resource_id         = azurerm_key_vault.esta.id
  log_analytics_workspace_id = var.workspace_id

  enabled_log { category = "AuditEvent" }
  enabled_log { category = "AzurePolicyEvaluationDetails" }

  enabled_metric { category = "AllMetrics" }
}
