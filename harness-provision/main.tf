# Create Organizations
module "bootstrap_harness_account" {
  source                         = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  harness_platform_organizations = local.harness_platform_organizations

  providers = {
    harness = harness.provisioner
  }
}

module "bootstrap_harness_delegates" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-delegate?ref=main"
  harness_platform_delegates = local.harness_platform_delegates
  harness_platform_api_key   = var.harness_platform_api_key
  harness_account_id         = var.harness_platform_account_id
}

output "account" {
  value = {
    organizations = module.bootstrap_harness_account.organization
    delegates     = module.bootstrap_harness_delegates.delegates
  }
}
