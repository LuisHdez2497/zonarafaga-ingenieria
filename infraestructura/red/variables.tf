variable "nombre" { type = string }
variable "grupo_recursos" { type = string }
variable "region" { type = string }
variable "espacio" {
  description = "Espacio de direcciones de la red. Un /21 deja sitio para crecer sin rehacerla."
  type        = string
  default     = "10.20.0.0/21"
}
variable "prefijo_dns" {
  description = "Prefijo de la zona DNS privada. Debe ser único por ambiente."
  type        = string
}
variable "etiquetas" { type = map(string) }
