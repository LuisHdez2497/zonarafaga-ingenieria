variable "nombre" { type = string }
variable "grupo_recursos" { type = string }
variable "region" { type = string }
variable "cadena_observabilidad" {
  description = "Cadena de conexión de Application Insights. La app manda sus trazas ahí."
  type        = string
  sensitive   = true
}
variable "imagen" {
  description = "Imagen del contenedor, identificada por digest. Una etiqueta móvil despliega algo distinto de lo verificado."
  type        = string
  validation {
    condition     = can(regex("@sha256:", var.imagen))
    error_message = "La imagen debe venir por digest (@sha256:...), no por etiqueta."
  }
}
variable "registro" {
  description = "Servidor del registro de contenedores."
  type        = string
}
variable "plan_sku" {
  description = "Tamaño del plan. Subir de escalón sube el costo de todas las apps del plan, no solo de una."
  type        = string
  default     = "B1"
  validation {
    condition     = contains(["B1", "B2", "B3", "S1", "P0v3", "P1v3"], var.plan_sku)
    error_message = "SKU fuera de la escala prevista. Ampliarla es una decisión, no un descuido."
  }
}
variable "siempre_encendida" {
  description = "Falso deja que la app se duerma sin tráfico: ahorra arranque, no dinero. El plan se paga igual."
  type        = bool
  default     = true
}
variable "puerto" {
  description = "Puerto que escucha el contenedor."
  type        = number
  default     = 3000
}
variable "etiquetas" { type = map(string) }

variable "subred_id" {
  description = "Subred delegada a serverFarms para la integración de red. No cuesta extra en ningún nivel dedicado."
  type        = string
}
variable "workspace_id" {
  description = "Workspace al que la app manda sus registros de plataforma."
  type        = string
}
