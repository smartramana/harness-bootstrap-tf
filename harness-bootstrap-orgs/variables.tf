variable "harness_platform_api_key" {
  sensitive = true
}
variable "harness_platform_account_id" {
  sensitive = true
}

locals {
  harness_platform_organizations = var.cristian_lab_orgs
  harness_platform_projects      = local.cristian_lab_org_projects
  harness_platform_delegates     = local.cristiab_account_delegates
}
