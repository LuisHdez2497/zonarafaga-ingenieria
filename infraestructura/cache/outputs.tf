output "host" { value = azurerm_redis_cache.este.hostname }
output "puerto" { value = azurerm_redis_cache.este.ssl_port }
output "clave_primaria" {
  value     = azurerm_redis_cache.este.primary_access_key
  sensitive = true
}
