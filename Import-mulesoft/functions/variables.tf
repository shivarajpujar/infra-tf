variable "env_prefix" {}
variable "resource_group" {}
variable "shared_resource_group" {}
variable "keyvault" {}
variable "service_bus_name" {}
variable "azure_tags" { type = map(string) }
variable "create_queue_enquire_local" {
  type    = bool
  default = false
}
variable "create_queue_sc_dealers_import" {
  type    = bool
  default = false
}
variable "function_app" {}
variable "app_service_plan" {}
variable "storage_account" {}
variable "application_insights" {}
variable "dealers_db_server" {}
variable "dealers_db" {}
variable "function_app_public_properties" { type = map(string) }
variable "function_app_private_properties" { type = map(string) }
