module "bootstrap_harness" {
  source                    = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  harness_platform_projects = local.harness_platform_projects

  providers = {
    harness = harness.provisioner
  }
}

module "bootstrap_harness_delegates" {
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-delegate?ref=main"
  harness_platform_delegates = local.harness_platform_delegates
  harness_platform_api_key   = var.harness_platform_api_key
}

module "bootstrap_harness_connectors" {
  depends_on = [
    module.bootstrap_harness,
    module.bootstrap_harness_delegates
  ]
  source                      = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-connectors?ref=main"
  harness_platform_connectors = local.harness_platform_connectors

  providers = {
    harness = harness.provisioner
  }
}

output "details" {
  value = {
    organization = module.bootstrap_harness.organization
    delegates    = module.bootstrap_harness_delegates.delegates
    project      = module.bootstrap_harness.project
  }
}
