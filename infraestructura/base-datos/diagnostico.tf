resource "azurerm_monitor_diagnostic_setting" "servidor" {
  name                       = "plataforma"
  target_resource_id         = azurerm_postgresql_flexible_server.este.id
  log_analytics_workspace_id = var.workspace_id

  enabled_log { category = "PostgreSQLLogs" }
  enabled_log { category = "PostgreSQLFlexSessions" }

  enabled_metric { category = "AllMetrics" }
}
