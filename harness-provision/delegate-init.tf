resource "harness_platform_service" "service" {
  identifier  = "delegate_${random_string.suffix.id}"
  name        = "delegate"
  org_id      = module.bootstrap_harness_account.organization[var.organization_prefix].org_id
  project_id  = module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id
  description = "Service registred by terraform harness provider"
}

resource "harness_platform_environment" "environment" {
  identifier  = "harness_${random_string.suffix.id}"
  name        = "harness"
  type        = "PreProduction"
  org_id      = module.bootstrap_harness_account.organization[var.organization_prefix].org_id
  project_id  = module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id
  description = "Environment registred by terraform harness provider"
}
