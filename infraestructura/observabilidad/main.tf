resource "azurerm_log_analytics_workspace" "este" {
  name                = var.nombre
  resource_group_name = var.grupo_recursos
  location            = var.region
  sku                 = "PerGB2018"
  retention_in_days   = var.retencion_dias

  tags = var.etiquetas
}

resource "azurerm_application_insights" "esta" {
  name                = "${var.nombre}-insights"
  resource_group_name = var.grupo_recursos
  location            = var.region
  workspace_id        = azurerm_log_analytics_workspace.este.id
  application_type    = "web"

  tags = var.etiquetas
}
