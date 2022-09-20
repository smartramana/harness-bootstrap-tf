variable "harness_platform_api_key" {
  sensitive = false
}
variable "harness_platform_account_id" {
  sensitive = false
}
variable "harness_connector_crizstian_github_token" {
  sensitive = true
}
variable "harness_connector_crizstian_docker_token" {
  sensitive = true
}
variable "harness_connector_crizstian_artifactory_token" {
  sensitive = true
}

locals {
  harness_platform_projects = tomap({
    "cristian-lab-org" = var.cristian_lab_org_projects
  })
  harness_platform_connectors = merge(
    local.cristiab_lab_org_connectors
  )
  harness_platform_delegates = tomap({
    k8s = merge(local.cristiab_lab_org_delegates.k8s)
  })
  harness_platform_secrets = merge(
    local.cristian_secrets_org
  )

  harness_template_endpoint_account_args = "?accountIdentifier=${var.harness_platform_account_id}&orgIdentifier=${module.bootstrap_harness_account.organization[var.cristian_lab_org_projects.organization_name].org_id}&storeType=INLINE&comments=terraform-generated"
}
