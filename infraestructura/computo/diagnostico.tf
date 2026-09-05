resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "plataforma"
  target_resource_id         = azurerm_linux_web_app.api.id
  log_analytics_workspace_id = var.workspace_id

  enabled_log { category = "AppServiceHTTPLogs" }
  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServiceAppLogs" }
  enabled_log { category = "AppServiceAuditLogs" }
  enabled_log { category = "AppServicePlatformLogs" }

  enabled_metric { category = "AllMetrics" }
}
