variable "nombre" { type = string }
variable "grupo_recursos" { type = string }
variable "region" { type = string }
variable "tenant_id" { type = string }
variable "retencion_dias" {
  description = "Días que un secreto borrado se puede recuperar."
  type        = number
  default     = 30
}
variable "etiquetas" { type = map(string) }

variable "workspace_id" { type = string }

variable "acceso_publico" {
  description = "Falso cierra la bóveda a todo lo que no venga de una subred permitida."
  type        = bool
  default     = false
}
variable "subredes_permitidas" {
  type    = list(string)
  default = []
}
