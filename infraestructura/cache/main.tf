# Azure Managed Redis (Balanced B0) sería más barato que esto y trae SLA y réplica,
# pero el proveedor azurerm 4.81 todavía no expone el recurso: solo `Enterprise_*`
# en el recurso obsoleto. Cuando lo exponga, este módulo cambia de recurso sin que
# el resto del stack se entere. Ver docs/adr/0011.
resource "azurerm_redis_cache" "este" {
  name                = var.nombre
  resource_group_name = var.grupo_recursos
  location            = var.region
  family              = var.familia
  capacity            = var.capacidad
  sku_name            = var.nivel

  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  non_ssl_port_enabled          = false

  tags = var.etiquetas
}

# Con el acceso público cerrado, la caché solo existe dentro de la red. El punto
# privado le da una dirección ahí y la zona DNS hace que su nombre resuelva a
# esa dirección y no a la pública.
resource "azurerm_private_endpoint" "este" {
  name                = "${var.nombre}-pe"
  resource_group_name = var.grupo_recursos
  location            = var.region
  subnet_id           = var.subred_id

  private_service_connection {
    name                           = "redis"
    private_connection_resource_id = azurerm_redis_cache.este.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "redis"
    private_dns_zone_ids = [var.zona_dns_id]
  }

  tags = var.etiquetas
}
