data "azurerm_client_config" "actual" {}

locals {
  prefijo = "zr-${var.ambiente}"
  # Los nombres globales no admiten guiones: van sin separador.
  prefijo_plano = "zr${var.ambiente}"

  # Etiquetas de costeo. Se fijan antes de crear el primer recurso: un recurso sin
  # etiqueta deja su gasto huérfano y no se puede reconstruir después.
  etiquetas = {
    proyecto       = "zonarafaga"
    ambiente       = var.ambiente
    gestionado_por = "terraform"
  }
}

resource "azurerm_resource_group" "este" {
  name     = "${local.prefijo}-rg"
  location = var.region
  tags     = local.etiquetas
}

resource "random_password" "base_datos" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "red" {
  source         = "../red"
  nombre         = "${local.prefijo}-red"
  grupo_recursos = azurerm_resource_group.este.name
  region         = azurerm_resource_group.este.location
  espacio        = var.red_espacio
  prefijo_dns    = local.prefijo
  etiquetas      = local.etiquetas
}

module "observabilidad" {
  source         = "../observabilidad"
  nombre         = "${local.prefijo}-logs"
  grupo_recursos = azurerm_resource_group.este.name
  region         = azurerm_resource_group.este.location
  retencion_dias = var.retencion_observabilidad_dias
  etiquetas      = local.etiquetas
}

module "base_datos" {
  source            = "../base-datos"
  nombre            = "${local.prefijo}-pg"
  grupo_recursos    = azurerm_resource_group.este.name
  region            = azurerm_resource_group.este.location
  sku               = var.base_datos_sku
  almacenamiento_mb = var.base_datos_mb
  contrasena        = random_password.base_datos.result

  subred_id               = module.red.subred_datos
  zona_dns_id             = module.red.zona_dns_postgres
  tenant_id               = data.azurerm_client_config.actual.tenant_id
  respaldo_geo_redundante = var.base_datos_respaldo_geo
  alta_disponibilidad     = var.base_datos_alta_disponibilidad
  workspace_id            = module.observabilidad.workspace_id
  retencion_respaldo_dias = var.base_datos_retencion_respaldo

  etiquetas = local.etiquetas

  depends_on = [module.red]
}

# Un ambiente sin caché no es un ambiente roto: la app degrada con elegancia
# (el contador de sesión falla abierto). Dos cachés ociosas sí son dinero tirado.
module "cache" {
  count          = var.cache_habilitada ? 1 : 0
  source         = "../cache"
  nombre         = "${local.prefijo}-redis"
  grupo_recursos = azurerm_resource_group.este.name
  region         = azurerm_resource_group.este.location
  familia        = var.cache_familia
  capacidad      = var.cache_capacidad
  nivel          = var.cache_nivel
  subred_id      = module.red.subred_privados
  zona_dns_id    = module.red.zona_dns_redis
  etiquetas      = local.etiquetas
}

module "almacen" {
  source         = "../almacen"
  nombre         = "${local.prefijo_plano}medios"
  grupo_recursos = azurerm_resource_group.este.name
  region         = azurerm_resource_group.este.location
  workspace_id   = module.observabilidad.workspace_id

  acceso_publico      = false
  subredes_permitidas = [module.red.subred_apps]

  etiquetas = local.etiquetas
}

module "secretos" {
  source         = "../secretos"
  nombre         = "${local.prefijo}-kv"
  grupo_recursos = azurerm_resource_group.este.name
  region         = azurerm_resource_group.este.location
  tenant_id      = data.azurerm_client_config.actual.tenant_id
  workspace_id   = module.observabilidad.workspace_id

  acceso_publico      = false
  subredes_permitidas = [module.red.subred_apps]

  etiquetas = local.etiquetas
}

module "computo" {
  source                = "../computo"
  nombre                = "${local.prefijo}-api"
  grupo_recursos        = azurerm_resource_group.este.name
  region                = azurerm_resource_group.este.location
  cadena_observabilidad = module.observabilidad.cadena_insights
  imagen                = var.imagen_api
  registro              = var.registro_servidor
  plan_sku              = var.computo_plan_sku
  siempre_encendida     = var.computo_siempre_encendida
  subred_id             = module.red.subred_apps
  workspace_id          = module.observabilidad.workspace_id
  etiquetas             = local.etiquetas
}

# La aplicación lee los secretos con su identidad administrada, sin credencial propia.
resource "azurerm_role_assignment" "app_lee_secretos" {
  scope                = module.secretos.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.computo.identidad
}

resource "azurerm_role_assignment" "app_escribe_medios" {
  scope                = module.almacen.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.computo.identidad
}

# Los secretos se guardan por referencia: la plantilla declara dónde viven, no su valor.
# Un secreto sin fecha de caducidad no se rota nunca: nadie sabe que tocaba.
resource "azurerm_key_vault_secret" "base_datos" {
  name            = "db-password"
  value           = random_password.base_datos.result
  key_vault_id    = module.secretos.id
  content_type    = "password"
  expiration_date = var.caducidad_secretos
}

resource "azurerm_key_vault_secret" "cache" {
  count           = var.cache_habilitada ? 1 : 0
  name            = "redis-key"
  value           = one(module.cache[*].clave_primaria)
  key_vault_id    = module.secretos.id
  content_type    = "access-key"
  expiration_date = var.caducidad_secretos
}
