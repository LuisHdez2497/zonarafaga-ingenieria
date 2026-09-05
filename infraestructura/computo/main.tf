resource "azurerm_service_plan" "este" {
  #checkov:skip=CKV_AZURE_211:Un plan Premium es la respuesta con trafico real; hoy no lo hay. El escalon se sube con la metrica de CPU
  #checkov:skip=CKV_AZURE_212:Una sola instancia es una decision de costo declarada en el ADR 0011, no un descuido
  #checkov:skip=CKV_AZURE_225:La redundancia de zona exige nivel Premium. Se decide con trafico, no antes
  name                = "${var.nombre}-plan"
  resource_group_name = var.grupo_recursos
  location            = var.region
  os_type             = "Linux"
  sku_name            = var.plan_sku

  tags = var.etiquetas
}

resource "azurerm_linux_web_app" "api" {
  #checkov:skip=CKV_AZURE_214:Se activa por ambiente. Produccion lo lleva; en dev y qa dormir la app no cuesta ni ahorra, y acorta el arranque en frio del despliegue
  #checkov:skip=CKV_AZURE_13:La API autentica con su propio JWT y RBAC; Easy Auth duplicaria el control de acceso en dos sitios que pueden divergir
  #checkov:skip=CKV_AZURE_17:Es una API publica consumida por navegador y por app movil; exigir certificado de cliente romperia a los dos
  #checkov:skip=CKV_AZURE_222:La API tiene que ser alcanzable desde internet: es el producto. Lo privado es todo lo que hay detras
  #checkov:skip=CKV_AZURE_88:No monta almacenamiento de archivos; los medios van a blob por la interfaz StorageProvider
  name                = var.nombre
  resource_group_name = var.grupo_recursos
  location            = var.region
  service_plan_id     = azurerm_service_plan.este.id
  https_only          = true

  # Sale a la red por su propia subred: así alcanza la base de datos privada.
  # El tráfico privado (RFC1918) va por aquí de forma predeterminada; el resto
  # sigue saliendo directo, que es lo que queremos para bajar la imagen.
  virtual_network_subnet_id = var.subred_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = var.siempre_encendida
    container_registry_use_managed_identity = true
    health_check_path                       = "/health"
    health_check_eviction_time_in_min       = 10
    http2_enabled                           = true
    minimum_tls_version                     = "1.2"
    ftps_state                              = "Disabled"

    application_stack {
      docker_image_name   = replace(var.imagen, "${var.registro}/", "")
      docker_registry_url = "https://${var.registro}"
    }
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  app_settings = {
    WEBSITES_PORT                         = tostring(var.puerto)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.cadena_observabilidad
  }

  tags = var.etiquetas
}
