resource "azurerm_key_vault" "esta" {
  #checkov:skip=CKV2_AZURE_32:El punto privado es el siguiente escalon; hoy la boveda niega por defecto y solo la alcanza la subred de aplicaciones
  name                          = var.nombre
  resource_group_name           = var.grupo_recursos
  location                      = var.region
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = var.retencion_dias
  purge_protection_enabled      = true
  rbac_authorization_enabled    = true
  public_network_access_enabled = var.acceso_publico

  # Negar por defecto y abrir por subred. `AzureServices` deja pasar a la propia
  # App Service para resolver las referencias a secretos al arrancar.
  network_acls {
    default_action             = var.acceso_publico ? "Allow" : "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.subredes_permitidas
  }

  tags = var.etiquetas
}
