# Create Organizations
module "bootstrap_harness_account" {
  source                         = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  harness_platform_organizations = var.harness_platform_organizations

  providers = {
    harness = harness.provisioner
  }
}

module "bootstrap_harness_delegates" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-delegate?ref=main"
  harness_platform_delegates = var.harness_platform_delegates
  harness_platform_api_key   = var.harness_platform_api_key
  harness_account_id         = var.harness_platform_account_id
}

module "bootstrap_harness_connectors" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                             = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-connectors?ref=main"
  harness_platform_github_connectors = local.github_connectors

  providers = {
    harness = harness.provisioner
  }
}

module "render_template_files" {
  depends_on = [
    module.bootstrap_harness_account,
    module.bootstrap_harness_delegates,
    module.bootstrap_harness_connectors
  ]
  source            = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-templates?ref=main"
  harness_templates = local.harness_templates
}

output "account" {
  value = {
    organizations = module.bootstrap_harness_account.organization
    delegates     = module.bootstrap_harness_delegates.delegates
    connectors    = module.bootstrap_harness_connectors.connectors
    files         = module.render_template_files.files
  }
}
