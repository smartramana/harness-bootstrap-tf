# Create Organizations
module "bootstrap_harness_account" {
  source                         = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  suffix                         = random_string.suffix.id
  harness_platform_organizations = var.harness_platform_organizations

  providers = {
    harness = harness.provisioner
  }
}

# Create Delegates and downloads the manifest (run locally only); manifests are not exported or upload to an artifact repository
module "bootstrap_harness_delegates" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-delegate?ref=main"
  harness_platform_delegates = var.harness_platform_delegates
  harness_platform_api_key   = var.harness_platform_api_key
  harness_account_id         = var.harness_platform_account_id
}

# Create connectors
module "bootstrap_harness_connectors" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                             = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-connectors?ref=main"
  suffix                             = random_string.suffix.id
  harness_platform_github_connectors = local.github_connectors

  providers = {
    harness = harness.provisioner
  }
}

# Creates Pipeline 
module "bootstrap_harness_pipelines" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-pipeline?ref=main"
  suffix                     = random_string.suffix.id
  harness_platform_pipelines = local.pipelines
}


output "organizations" {
  value = module.bootstrap_harness_account.organization
}
output "delegates" {
  value = module.bootstrap_harness_delegates.delegates
}
output "connectors" {
  value = module.bootstrap_harness_connectors.connectors
}
output "pipelines" {
  value = module.bootstrap_harness_pipelines.pipelines
}
output "inputsets" {
  value = module.bootstrap_harness_pipelines.inputsets
}
