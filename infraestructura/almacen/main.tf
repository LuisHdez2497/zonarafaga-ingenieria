resource "azurerm_storage_account" "este" {
  #checkov:skip=CKV_AZURE_33:No se usa el servicio de colas; los medios van a blob y su acceso ya se registra en el ajuste de diagnostico
  #checkov:skip=CKV_AZURE_206:ZRS reparte las copias entre las zonas de la propia region. GRS las sacaria de ahi, que es justo lo que el ADR 0011 evita en prod
  #checkov:skip=CKV2_AZURE_1:Las llaves gestionadas por la plataforma cubren el requisito; una llave propia anade una rotacion que nadie opera
  #checkov:skip=CKV2_AZURE_33:El punto privado entra cuando la app deje de salir a internet; hoy el acceso se acota por subred y por identidad
  name                            = var.nombre
  resource_group_name             = var.grupo_recursos
  location                        = var.region
  account_tier                    = "Standard"
  account_replication_type        = var.replicacion
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = var.acceso_publico

  network_rules {
    default_action             = var.acceso_publico ? "Allow" : "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = var.subredes_permitidas
  }

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = var.retencion_borrado_dias
    }
  }

  tags = var.etiquetas
}

resource "azurerm_storage_container" "medios" {
  #checkov:skip=CKV2_AZURE_21:El registro de lectura de blobs se declara en el ajuste de diagnostico de la cuenta, no en el contenedor
  name                  = "medios"
  storage_account_id    = azurerm_storage_account.este.id
  container_access_type = "private"
}

resource "azurerm_monitor_diagnostic_setting" "blob" {
  name                       = "acceso"
  target_resource_id         = "${azurerm_storage_account.este.id}/blobServices/default"
  log_analytics_workspace_id = var.workspace_id

  enabled_log { category = "StorageRead" }
  enabled_log { category = "StorageWrite" }
  enabled_log { category = "StorageDelete" }

  enabled_metric { category = "Transaction" }
}
