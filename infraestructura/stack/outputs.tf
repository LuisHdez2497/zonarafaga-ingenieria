output "url_api" { value = module.computo.url }
output "grupo_recursos" { value = azurerm_resource_group.este.name }
output "boveda" { value = module.secretos.uri }
output "base_datos_host" { value = module.base_datos.host }
