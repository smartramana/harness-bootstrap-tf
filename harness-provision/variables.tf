variable "harness_platform_account_id" {}
variable "harness_platform_organizations" {}
variable "harness_platform_delegates" {}
variable "harness_platform_github_connectors" {}

variable "organization_prefix" {
  default = ""
}
variable "harness_platform_api_key" {
  sensitive = true
}

locals {
  github_connectors = { for name, details in var.harness_platform_github_connectors : name => {
    enable          = details.enable
    description     = details.description
    connection_type = details.connection_type
    url             = details.url
    validation_repo = details.connection_type == "Repo" ? "" : details.validation_repo
    org_id          = details.connection_type == "Repo" ? module.bootstrap_harness_account.organization[var.organization_prefix].org_id : try(details.org_id, "")
    project_id      = details.connection_type == "Repo" ? module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id : try(details.project_id, "")
    credentials = {
      http = {
        username     = details.credentials.http.username
        token_ref_id = try(details.credentials.http.token_ref_id, "")
      }
    }
    api_authentication = {
      token_ref = try(details.credentials.http.token_ref_id, "")
    }
  } if details.enable }

}
