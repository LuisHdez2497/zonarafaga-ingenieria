resource "azurerm_postgresql_flexible_server" "este" {
  #checkov:skip=CKV_AZURE_136:Se activa por ambiente. Produccion lo lleva; perder dev o qa no es un evento de negocio
  #checkov:skip=CKV2_AZURE_57:El servidor usa integracion de red delegada, no punto privado. Es el modo privado nativo de Flexible Server
  name                = var.nombre
  resource_group_name = var.grupo_recursos
  location            = var.region
  version             = "16"

  sku_name   = var.sku
  storage_mb = var.almacenamiento_mb

  administrator_login    = var.administrador
  administrator_password = var.contrasena

  backup_retention_days        = var.retencion_respaldo_dias
  geo_redundant_backup_enabled = var.respaldo_geo_redundante

  # El servidor no tiene dirección pública: vive en su subred y solo lo alcanza
  # quien esté en la red. Es lo que separa una base de datos privada de una
  # pública con una lista de direcciones permitidas.
  public_network_access_enabled = false
  delegated_subnet_id           = var.subred_id
  private_dns_zone_id           = var.zona_dns_id

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = var.tenant_id
  }

  dynamic "high_availability" {
    for_each = var.alta_disponibilidad ? [1] : []
    content {
      mode = "SameZone"
    }
  }

  tags = var.etiquetas

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "app"
  server_id = azurerm_postgresql_flexible_server.este.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  lifecycle {
    prevent_destroy = true
  }
}
