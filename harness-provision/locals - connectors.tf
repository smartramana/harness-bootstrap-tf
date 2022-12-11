# github connectors
locals {
  github_connectors = { for key, value in var.harness_platform_github_connectors : key => merge(value, {
    org_id     = try(value.seed_connector, false) ? module.bootstrap_harness_account.organization[var.organization_prefix].org_id : ""
    project_id = try(value.seed_connector, false) ? module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id : ""
  }) }
}
