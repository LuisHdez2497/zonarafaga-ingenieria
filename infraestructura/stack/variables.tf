variable "ambiente" {
  description = "Nombre del ambiente. Entra en el nombre de cada recurso y en las etiquetas de costeo."
  type        = string
  validation {
    condition     = contains(["dev", "qa", "prod"], var.ambiente)
    error_message = "El ambiente debe ser dev, qa o prod."
  }
}

variable "region" {
  type    = string
  default = "mexicocentral"
}

variable "imagen_api" {
  description = "Imagen de la API por digest."
  type        = string
}

variable "registro_servidor" {
  description = "Servidor del registro de contenedores, compartido entre ambientes."
  type        = string
}

variable "base_datos_sku" { type = string }
variable "base_datos_mb" { type = number }
variable "cache_habilitada" {
  description = "Solo producción la necesita gestionada. La app degrada sin ella."
  type        = bool
  default     = false
}
variable "cache_familia" {
  type    = string
  default = "C"
}
variable "cache_capacidad" {
  type    = number
  default = 0
}
variable "cache_nivel" {
  type    = string
  default = "Standard"
}
variable "computo_plan_sku" {
  description = "Tamaño del plan de App Service. El cómputo se paga por plan, no por app."
  type        = string
  default     = "B1"
}
variable "computo_siempre_encendida" {
  type    = bool
  default = true
}
variable "retencion_observabilidad_dias" {
  type    = number
  default = 30
}

variable "red_espacio" {
  type    = string
  default = "10.20.0.0/21"
}
variable "base_datos_respaldo_geo" {
  type    = bool
  default = false
}
variable "base_datos_alta_disponibilidad" {
  type    = bool
  default = false
}
variable "base_datos_retencion_respaldo" {
  type    = number
  default = 7
}
variable "presupuesto_mensual" {
  description = "Tope mensual en USD del grupo de recursos. Avisa al 80% real y al 100% pronosticado."
  type        = number
}
variable "presupuesto_inicio" {
  description = "Primer día del periodo, en formato AAAA-MM-01T00:00:00Z."
  type        = string
}
variable "contactos_presupuesto" {
  type = list(string)
}
variable "candado_borrado" {
  description = "Candado de no-borrado en el grupo de recursos. Solo producción."
  type        = bool
  default     = false
}

variable "caducidad_secretos" {
  description = "Fecha ISO-8601 en que caducan los secretos generados. Rotarlos es sustituir esta fecha y aplicar."
  type        = string
}
