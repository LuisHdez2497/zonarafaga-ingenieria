output "subred_apps" { value = azurerm_subnet.apps.id }
output "subred_datos" { value = azurerm_subnet.datos.id }
output "zona_dns_postgres" { value = azurerm_private_dns_zone.postgres.id }
output "enlace_dns" {
  description = "El servidor no se puede crear antes que el enlace de la zona; se depende de esto explícitamente."
  value       = azurerm_private_dns_zone_virtual_network_link.postgres.id
}
output "subred_privados" { value = azurerm_subnet.privados.id }
output "zona_dns_redis" { value = azurerm_private_dns_zone.redis.id }
