resource "azurerm_virtual_network" "esta" {
  name                = var.nombre
  resource_group_name = var.grupo_recursos
  location            = var.region
  address_space       = [var.espacio]

  tags = var.etiquetas
}

# La integración de red de App Service exige una subred propia y delegada, de
# /28 o mayor. Se toma /27 porque cada instancia del plan consume una dirección
# y la subred no se puede redimensionar después de asignarla.
resource "azurerm_subnet" "apps" {
  name                 = "apps"
  resource_group_name  = var.grupo_recursos
  virtual_network_name = azurerm_virtual_network.esta.name
  address_prefixes     = [cidrsubnet(var.espacio, 6, 0)]

  delegation {
    name = "serverfarms"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "datos" {
  name                 = "datos"
  resource_group_name  = var.grupo_recursos
  virtual_network_name = azurerm_virtual_network.esta.name
  address_prefixes     = [cidrsubnet(var.espacio, 6, 1)]

  delegation {
    name = "flexibleservers"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Un punto privado no puede vivir en una subred delegada: necesita la suya.
resource "azurerm_subnet" "privados" {
  name                 = "privados"
  resource_group_name  = var.grupo_recursos
  virtual_network_name = azurerm_virtual_network.esta.name
  address_prefixes     = [cidrsubnet(var.espacio, 6, 2)]
}

resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.grupo_recursos

  tags = var.etiquetas
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                  = "redis"
  resource_group_name   = var.grupo_recursos
  private_dns_zone_name = azurerm_private_dns_zone.redis.name
  virtual_network_id    = azurerm_virtual_network.esta.id
  registration_enabled  = false

  tags = var.etiquetas
}

# Sin la zona privada, el nombre del servidor resuelve a su dirección pública y
# la integración de red no sirve de nada: el tráfico saldría a internet igual.
resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.prefijo_dns}.private.postgres.database.azure.com"
  resource_group_name = var.grupo_recursos

  tags = var.etiquetas
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgres"
  resource_group_name   = var.grupo_recursos
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.esta.id
  registration_enabled  = false

  tags = var.etiquetas
}

# La subred de datos no habla con internet ni con la de aplicaciones más que
# por el puerto de PostgreSQL. Es la diferencia entre una red y una lista de
# direcciones.
resource "azurerm_network_security_group" "datos" {
  name                = "${var.nombre}-datos-nsg"
  resource_group_name = var.grupo_recursos
  location            = var.region

  security_rule {
    name                       = "permitir-postgres-desde-apps"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = cidrsubnet(var.espacio, 6, 0)
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "negar-lo-demas"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.etiquetas
}

resource "azurerm_subnet_network_security_group_association" "datos" {
  subnet_id                 = azurerm_subnet.datos.id
  network_security_group_id = azurerm_network_security_group.datos.id
}

# La subred de aplicaciones no recibe tráfico entrante: la integración de red es
# solo de salida. El grupo existe para que eso quede escrito y auditable.
resource "azurerm_network_security_group" "apps" {
  name                = "${var.nombre}-apps-nsg"
  resource_group_name = var.grupo_recursos
  location            = var.region

  security_rule {
    name                       = "negar-entrante"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.etiquetas
}

resource "azurerm_subnet_network_security_group_association" "apps" {
  subnet_id                 = azurerm_subnet.apps.id
  network_security_group_id = azurerm_network_security_group.apps.id
}

# A la subred de puntos privados solo entra la de aplicaciones. Un punto privado
# sin grupo de seguridad es alcanzable desde cualquier sitio de la red.
resource "azurerm_network_security_group" "privados" {
  name                = "${var.nombre}-privados-nsg"
  resource_group_name = var.grupo_recursos
  location            = var.region

  security_rule {
    name                       = "permitir-desde-apps"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = cidrsubnet(var.espacio, 6, 0)
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "negar-lo-demas"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.etiquetas
}

resource "azurerm_subnet_network_security_group_association" "privados" {
  subnet_id                 = azurerm_subnet.privados.id
  network_security_group_id = azurerm_network_security_group.privados.id
}
