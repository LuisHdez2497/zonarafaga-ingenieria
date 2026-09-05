variable "nombre" {
  description = "Nombre de la cuenta. Solo minúsculas y números, de 3 a 24 caracteres."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.nombre))
    error_message = "Solo minúsculas y números, entre 3 y 24 caracteres."
  }
}
variable "grupo_recursos" { type = string }
variable "region" { type = string }
variable "replicacion" {
  description = "ZRS reparte las copias entre zonas de la región; LRS las deja en un solo centro."
  type        = string
  default     = "ZRS"
}
variable "retencion_borrado_dias" {
  description = "Borrado suave. Protege del borrado accidental, no solo de la falla de disco."
  type        = number
  default     = 30
}
variable "etiquetas" { type = map(string) }

variable "workspace_id" { type = string }
variable "acceso_publico" {
  description = "Falso cierra la cuenta a todo lo que no venga de una subred permitida."
  type        = bool
  default     = false
}
variable "subredes_permitidas" {
  description = "Subredes que sí pueden alcanzar la cuenta cuando el acceso público está cerrado."
  type        = list(string)
  default     = []
}
