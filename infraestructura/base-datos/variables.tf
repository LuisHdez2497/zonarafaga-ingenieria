variable "nombre" {
  description = "Nombre del servidor. Debe ser único en todo Azure."
  type        = string
}

variable "grupo_recursos" {
  description = "Grupo de recursos donde vive el servidor."
  type        = string
}

variable "region" {
  description = "Región de Azure."
  type        = string
}

variable "sku" {
  description = "Tamaño del cómputo. Los B* son ráfaga y bastan hasta que el consumo sea estable."
  type        = string
  validation {
    condition     = can(regex("^(B_|GP_|MO_)", var.sku))
    error_message = "El sku debe empezar con B_, GP_ o MO_."
  }
}

variable "almacenamiento_mb" {
  description = "Almacenamiento en MB. Solo crece: Azure no permite reducirlo."
  type        = number
  validation {
    condition     = var.almacenamiento_mb >= 32768
    error_message = "El mínimo que acepta Azure son 32768 MB."
  }
}

variable "retencion_respaldo_dias" {
  description = "Días de retención del respaldo. La regla de recuperación pide 35."
  type        = number
  default     = 35
}

variable "administrador" {
  description = "Usuario administrador. Su contraseña no vive aquí: se genera y se guarda en la bóveda."
  type        = string
  default     = "zradmin"
}

variable "contrasena" {
  description = "Contraseña del administrador, generada fuera del módulo."
  type        = string
  sensitive   = true
}

variable "etiquetas" {
  description = "Etiquetas de costeo. Sin ellas el gasto queda huérfano."
  type        = map(string)
}

variable "subred_id" {
  description = "Subred delegada donde vive el servidor. Sin ella no hay acceso privado."
  type        = string
}
variable "zona_dns_id" {
  description = "Zona DNS privada que resuelve el nombre del servidor dentro de la red."
  type        = string
}
variable "tenant_id" { type = string }
variable "respaldo_geo_redundante" {
  description = "Copia los respaldos a la región emparejada. Es lo que hace real un RPO ante pérdida de región."
  type        = bool
  default     = false
}
variable "alta_disponibilidad" {
  description = "Servidor en espera. Sube el SLA de 99.9 a 99.95 y duplica el costo de cómputo."
  type        = bool
  default     = false
}

variable "workspace_id" { type = string }
