variable "harness_platform_account_id" {}
variable "harness_platform_organizations" {}
variable "harness_platform_api_key" {
  sensitive = true
}
variable "harness_platform_delegates" {
  default = {}
}
variable "harness_platform_github_connectors" {
  default = {}
}
variable "harness_platform_pipelines" {
  default = {}
}
variable "harness_platform_inputsets" {
  default = {}
}
# ---
variable "custom_templates" {
  default = {}
}
variable "organization_prefix" {
  default = ""
}

locals {
  common_schema = {
    org_id     = module.bootstrap_harness_account.organization[var.organization_prefix].org_id
    project_id = module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id
    suffix     = module.bootstrap_harness_account.organization[var.organization_prefix].suffix
  }

  github_connectors = { for name, details in var.harness_platform_github_connectors : name => merge(
    details,
    {
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
  }) if details.enable }

  pipeline_templates = { for key, details in var.custom_templates.pipelines : key => merge(
    details,
    {
      vars = merge(
        details.vars,
        local.common_schema,
        {
          name              = key
          git_connector_ref = module.bootstrap_harness_connectors.connectors.github_connectors["devsecops_connector_github_connector"]
        }
      )
  }) }

  pipelines = { for name, details in var.harness_platform_pipelines : name => merge(
    details,
    local.common_schema,
    {
      yaml = data.local_file.pipeline_template[name].content
    }
  ) }

  inputset_templates = { for key, details in var.custom_templates.inputsets : key => merge(
    details,
    {
      vars = merge(
        details.vars,
        local.common_schema,
        {
          name           = key
          pipeline_id    = module.bootstrap_harness_pipelines.pipelines[var.harness_platform_inputsets[key].pipeline].pipeline_id
          tf_workspace   = terraform.workspace
          tf_remote_vars = "tfvars/${terraform.workspace}/account.tfvars"
      })
  }) }

  inputsets = { for name, details in var.harness_platform_inputsets : name => merge(
    details,
    local.common_schema,
    {
      pipeline_id = module.bootstrap_harness_pipelines.pipelines[details.pipeline].pipeline_id
      yaml        = data.local_file.inputset_template[name].content
  }) if can(var.harness_platform_pipelines[details.pipeline]) }
}
