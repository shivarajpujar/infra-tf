locals {
  storage = {
    account_tier                           = "Standard"
    account_replication_type               = "LRS"
    legacy_storage_account_kind            = "Storage"
    legacy_storage_account_min_tls_version = "TLS1_0"
    containers = [
      "azure-webjobs-hosts",
      "azure-webjobs-secrets"
    ]
  }
  application_insights = {
    application_type           = "web"
    legacy_sampling_percentage = 0
  }
  function_app = {
    legacy_builtin_logging_enabled     = false
    legacy_client_certificate_mode     = "Required"
    legacy_functions_extension_version = "~1"
    connections = {
      dealers = {
        name              = "DealersContext"
        type              = "SQLAzure"
        connection_string = "Server=tcp:${var.dealers_db_server}.database.windows.net,1433;Initial Catalog=${var.dealers_db};Persist Security Info=False;User ID=${data.azurerm_key_vault_secret.dealers_db_user.value};Password=${data.azurerm_key_vault_secret.dealers_db_password.value};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;"
      }
    }
    site_config = {
      legacy_ftps_state              = "AllAllowed"
      legacy_http2_enabled           = true
      legacy_scm_minimum_tls_version = "1.0"
      legacy_use_32_bit_worker       = false

      cors = {
        legacy_allowed_origins = [
          "https://functions-next.azure.com",
          "https://functions-staging.azure.com",
          "https://functions.azure.com"
        ]

        legacy_support_credentials = false
      }
    }
  }
}

data "azurerm_service_plan" "main" {
  name                = var.app_service_plan
  resource_group_name = var.resource_group
}

data "azurerm_storage_account" "main" {
  name                = var.storage_account
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_key_vault" "main" {
  name                = var.keyvault
  resource_group_name = var.shared_resource_group
}

data "azurerm_key_vault_secret" "dealers_db_user" {
  name         = "${var.env_prefix}-sql-server-admin-user"
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azurerm_key_vault_secret" "dealers_db_password" {
  name         = "${var.env_prefix}-sql-server-admin-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

module "vars_from_keyvault" {
  source                  = "../vars_from_keyvault"
  keyvault_name           = var.keyvault
  keyvault_resource_group = var.shared_resource_group
  vars_secrets_map        = var.function_app_private_properties
}

resource "azurerm_storage_container" "main" {
  for_each             = toset(local.storage.containers)
  name                 = each.key
  storage_account_name = data.azurerm_storage_account.main.name
}

resource "azurerm_application_insights" "main" {
  name                = var.application_insights
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  application_type    = local.application_insights.application_type
  sampling_percentage = local.application_insights.legacy_sampling_percentage
  tags                = var.azure_tags
}

resource "azurerm_windows_function_app" "main" {
  name                        = var.function_app
  resource_group_name         = data.azurerm_resource_group.main.name
  location                    = data.azurerm_resource_group.main.location
  service_plan_id             = data.azurerm_service_plan.main.id
  storage_account_name        = data.azurerm_storage_account.main.name
  storage_account_access_key  = data.azurerm_storage_account.main.primary_access_key
  builtin_logging_enabled     = local.function_app.legacy_builtin_logging_enabled
  client_certificate_mode     = local.function_app.legacy_client_certificate_mode
  functions_extension_version = local.function_app.legacy_functions_extension_version
  tags = merge(
    var.azure_tags,
    {
      "hidden-link: /app-insights-instrumentation-key" : azurerm_application_insights.main.instrumentation_key
      "hidden-link: /app-insights-resource-id" : azurerm_application_insights.main.id
    }
  )

  site_config {
    application_insights_connection_string = azurerm_application_insights.main.connection_string
    application_insights_key               = azurerm_application_insights.main.instrumentation_key
    ftps_state                             = local.function_app.site_config.legacy_ftps_state
    http2_enabled                          = local.function_app.site_config.legacy_http2_enabled
    scm_minimum_tls_version                = local.function_app.site_config.legacy_scm_minimum_tls_version
    use_32_bit_worker                      = local.function_app.site_config.legacy_use_32_bit_worker
    cors {
      allowed_origins     = local.function_app.site_config.cors.legacy_allowed_origins
      support_credentials = local.function_app.site_config.cors.legacy_support_credentials
    }
  }
  app_settings = merge(
    var.function_app_public_properties,
    module.vars_from_keyvault.var_secrets,
    {
      "ServiceBusConnectionString" = azurerm_servicebus_namespace.main.default_primary_connection_string
    }
  )

  connection_string {
    name  = local.function_app.connections.dealers.name
    type  = local.function_app.connections.dealers.type
    value = local.function_app.connections.dealers.connection_string
  }
}