# github connectors
locals {
  github_connectors = { for key, value in var.harness_platform_github_connectors : key => merge(value, {
    org_id     = can(value.seed_connector) && value.seed_connector ? module.bootstrap_harness_account.organization[var.organization_prefix].org_id : ""
    project_id = can(value.seed_connector) && value.seed_connector ? module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id : ""
  }) }
}
