locals {
  service_bus_sku         = "Basic"
  queue_enquire           = "enquire"
  queue_enquire_local     = "enquire-local"
  queue_sc_dealers_import = "sc-dealers-import"
}

resource "azurerm_servicebus_namespace" "main" {
  name                = var.service_bus_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = local.service_bus_sku
  tags                = var.azure_tags
}

resource "azurerm_servicebus_queue" "enquire" {
  name         = local.queue_enquire
  namespace_id = azurerm_servicebus_namespace.main.id
}

resource "azurerm_servicebus_queue" "enquire_local" {
  count        = var.create_queue_enquire_local ? 1 : 0
  name         = local.queue_enquire_local
  namespace_id = azurerm_servicebus_namespace.main.id
}

resource "azurerm_servicebus_queue" "sc_dealers_import" {
  count        = var.create_queue_sc_dealers_import ? 1 : 0
  name         = local.queue_sc_dealers_import
  namespace_id = azurerm_servicebus_namespace.main.id
}