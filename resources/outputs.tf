# output "cosmos_connection_string" {
#   value = "${azurerm_cosmosdb_account.db.connection_strings}"
# }

output "blob_connection_string" {
  value = "${azurerm_storage_account.acc.primary_connection_string}"
}
