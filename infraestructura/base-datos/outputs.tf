output "id" {
  description = "Identificador del servidor."
  value       = azurerm_postgresql_flexible_server.este.id
}

output "host" {
  description = "Nombre de host para la cadena de conexión."
  value       = azurerm_postgresql_flexible_server.este.fqdn
}

output "base_datos" {
  description = "Nombre de la base de datos de la aplicación."
  value       = azurerm_postgresql_flexible_server_database.app.name
}
