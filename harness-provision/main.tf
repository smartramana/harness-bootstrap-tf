# Create Organizations
module "bootstrap_harness_account" {
  source                         = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
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
  harness_platform_github_connectors = local.github_connectors

  providers = {
    harness = harness.provisioner
  }
}

# Renders Pipeline and InputSet files in order to provision it with terraform
module "render_template_files" {
  depends_on = [
    module.bootstrap_harness_account,
    module.bootstrap_harness_delegates,
    module.bootstrap_harness_connectors
  ]
  source            = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-templates?ref=main"
  harness_templates = local.pipeline_templates
}

# Loads Pipeline and InputSet files in order to provision it with terraform
data "local_file" "template" {
  depends_on = [
    module.render_template_files
  ]
  for_each = local.pipeline_templates
  filename = "${path.module}/${each.key}.yml"
}

# Creates Pipeline and InputSet 
module "bootstrap_harness_pipelines" {
  depends_on = [
    module.render_template_files
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-pipeline?ref=main"
  harness_platform_pipelines = local.pipelines
}

# Creates Pipeline and InputSet 
module "bootstrap_harness_inputsets" {
  depends_on = [
    module.render_template_files
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-pipeline?ref=main"
  harness_platform_inputsets = local.pipelines
}

output "account" {
  value = {
    organizations = module.bootstrap_harness_account.organization
    delegates     = module.bootstrap_harness_delegates.delegates
    connectors    = module.bootstrap_harness_connectors.connectors
    pipelines     = module.bootstrap_harness_pipelines.pipelines
    inputsets     = module.bootstrap_harness_inputsets.inputsets
  }
}
