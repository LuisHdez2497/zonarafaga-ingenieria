output "url" { value = "https://${azurerm_linux_web_app.api.default_hostname}" }
output "identidad" {
  description = "Identidad administrada de la app. Es lo que le da acceso a la bóveda sin credencial propia."
  value       = azurerm_linux_web_app.api.identity[0].principal_id
}
output "plan_id" {
  description = "Permite colgar más apps del mismo plan: el cómputo se paga por plan, no por app."
  value       = azurerm_service_plan.este.id
}
