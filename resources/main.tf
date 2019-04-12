resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "westeurope"
  tags     = "${var.default_tags}"
}

resource "azurerm_application_insights" "insights" {
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  application_type    = "Web"
  name                = "terraformexample-appinsights-${var.environment}"

  tags = "${var.default_tags}"
}

resource "azurerm_storage_account" "acc" {
  name                     = "terraformexamplestorage${var.environment}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "rawcontainer" {
  name                  = "terraformexample-raw"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.acc.name}"
  container_access_type = "private"
}

resource "azurerm_iothub" "iothub" {
  name                = "terraformexample-iothub-${var.environment}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  sku {
    name     = "B1"
    tier     = "Basic"
    capacity = "1"
  }

  endpoint {
    type                       = "AzureIotHub.StorageContainer"
    connection_string          = "${azurerm_storage_account.acc.primary_blob_connection_string}"
    name                       = "terraformexample-raw"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    container_name             = "${azurerm_storage_container.rawcontainer.name}"
    encoding                   = "Avro"
    file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  }

  route {
    name           = "Default"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["events"]
    enabled        = true
  }

  route {
    name           = "terraformexample-all-route"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["terraformexample-raw"]
    enabled        = true
  }

  tags = "${var.default_tags}"
}

resource "azurerm_iothub_consumer_group" "functionsconsumer" {
  name                   = "tablestoragefunction"
  iothub_name            = "${azurerm_iothub.iothub.name}"
  eventhub_endpoint_name = "events"
  resource_group_name    = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "terraformexample-appserviceplan-${var.environment}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  kind                = "Windows"
  tags                = "${var.default_tags}"

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "frontend" {
  name                = "terraformexample-frontend-${var.environment}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appserviceplan.id}"
  tags                = "${var.default_tags}"

  # Do not attach Storage by default
  app_settings {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    APPINSIGHTS_INSTRUMENTATIONKEY     = "${azurerm_application_insights.insights.instrumentation_key}"
    WEBSITE_HTTPLOGGING_RETENTION_DAYS = "1"
    WEBSITE_RUN_FROM_PACKAGE           = "1"
    #Database__ServiceEndpoint          = "${azurerm_cosmosdb_account.db.endpoint}"
    #Database__AuthKey                  = "${azurerm_cosmosdb_account.db.primary_master_key}"
  }
  
  lifecycle {
    ignore_changes = [
      "app_settings.%",
      "site_config.0.scm_type",
    ]
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_function_app" "functionapp" {
  name                      = "terraformexample-functionapp-${var.environment}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.appserviceplan.id}"
  storage_connection_string = "${azurerm_storage_account.acc.primary_connection_string}"

  app_settings {
    APPINSIGHTS_INSTRUMENTATIONKEY     = "${azurerm_application_insights.insights.instrumentation_key}"
    WEBSITE_RUN_FROM_PACKAGE           = "1"
  }
}

# resource "azurerm_cosmosdb_account" "db" {
#   name                = "terraformexample-cosmos-${var.environment}"
#   location            = "${azurerm_resource_group.rg.location}"
#   resource_group_name = "${azurerm_resource_group.rg.name}"
#   offer_type          = "Standard"                              # Premium for Production => garanteed resources
#   kind                = "GlobalDocumentDB"                      # maybe MongoDB?
#   tags                = "${var.default_tags}"

#   enable_automatic_failover = false

#   consistency_policy {
#     consistency_level = "Session"
#   }

#   geo_location {
#     location          = "${azurerm_resource_group.rg.location}"
#     failover_priority = 0
#   }
# }
