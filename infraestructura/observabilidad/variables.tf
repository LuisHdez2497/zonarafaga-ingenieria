variable "nombre" { type = string }
variable "grupo_recursos" { type = string }
variable "region" { type = string }
variable "retencion_dias" {
  description = "Días que se conservan registros y métricas."
  type        = number
  default     = 30
}
variable "etiquetas" { type = map(string) }
