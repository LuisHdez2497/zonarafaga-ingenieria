output "workspace_id" { value = azurerm_log_analytics_workspace.este.id }
output "clave_workspace" {
  value     = azurerm_log_analytics_workspace.este.primary_shared_key
  sensitive = true
}
output "cliente_workspace" { value = azurerm_log_analytics_workspace.este.workspace_id }
output "cadena_insights" {
  value     = azurerm_application_insights.esta.connection_string
  sensitive = true
}
