variable "harness_platform_api_key" {
  sensitive = true
}
variable "harness_platform_account_id" {
  sensitive = true
}

locals {
  harness_platform_organizations = var.cristian_lab_orgs
  harness_platform_delegates     = local.cristiab_account_delegates
  harness_platform_secrets       = local.cristian_account_secrets

  # harness_platform_connectors = merge(
  #   local.cristiab_lab_org_connectors
  # )

  # harness_template_endpoint_account_args = "?accountIdentifier=${var.harness_platform_account_id}&orgIdentifier=${module.bootstrap_harness_account.organization[var.cristian_lab_org_projects.organization_name].org_id}&storeType=INLINE&comments=terraform-generated"
}
