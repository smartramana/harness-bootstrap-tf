variable "harness_platform_account_id" {
  sensitive = true
}
variable "harness_platform_api_key" {
  sensitive = true
}

locals {
  harness_platform_organizations = merge(local.cristian_lab_organizations)
  harness_platform_delegates     = local.cristian_account_delegates
}
