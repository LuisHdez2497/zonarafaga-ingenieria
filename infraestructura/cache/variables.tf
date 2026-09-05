variable "nombre" { type = string }
variable "grupo_recursos" { type = string }
variable "region" { type = string }
variable "familia" {
  description = "C para el nivel básico y estándar, P para premium."
  type        = string
  default     = "C"
}
variable "capacidad" {
  description = "Tamaño dentro de la familia. Subir un escalón duplica el costo."
  type        = number
  default     = 0
}
variable "nivel" {
  description = "Basic no tiene réplica ni SLA: un reinicio vacía la caché y las colas. Producción va en Standard."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.nivel)
    error_message = "Nivel inválido."
  }
}
variable "etiquetas" { type = map(string) }

variable "subred_id" {
  description = "Subred sin delegar donde aterriza el punto privado."
  type        = string
}
variable "zona_dns_id" {
  description = "Zona privada privatelink.redis.cache.windows.net enlazada a la red."
  type        = string
}
