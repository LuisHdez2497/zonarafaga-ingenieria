# Un presupuesto no impide gastar: avisa. Es la diferencia entre enterarse el
# día 8 y enterarse cuando llega la factura.
resource "azurerm_consumption_budget_resource_group" "este" {
  name              = "${local.prefijo}-presupuesto"
  resource_group_id = azurerm_resource_group.este.id
  amount            = var.presupuesto_mensual
  time_grain        = "Monthly"

  time_period {
    start_date = var.presupuesto_inicio
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.contactos_presupuesto
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.contactos_presupuesto
  }
}

# `prevent_destroy` solo protege de Terraform. Un borrado desde el portal pasa
# por encima; el candado no.
resource "azurerm_management_lock" "grupo" {
  count      = var.candado_borrado ? 1 : 0
  name       = "no-borrar"
  scope      = azurerm_resource_group.este.id
  lock_level = "CanNotDelete"
  notes      = "Producción. Quitar el candado es una decisión deliberada, no un paso de un script."
}
