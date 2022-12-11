# Create Organizations
module "bootstrap_harness_account" {
  source                         = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  suffix                         = random_string.suffix.id
  tags                           = local.common_tags.tags
  harness_platform_organizations = var.harness_platform_organizations
}

# Creates and uploads delegates manifests to Harness FileStore: => Account/Org/File
# Configures delegates at Account Level
# TODO: Auto Install delegates
module "bootstrap_harness_delegates" {
  depends_on = [
    module.bootstrap_harness_account
  ]
  source = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-delegate?ref=main"

  suffix                = random_string.suffix.id
  tags                  = local.common_tags.tags
  delegate_init_service = local.delegate_init_service

  harness_platform_api_key   = var.harness_platform_api_key
  harness_account_id         = var.harness_platform_account_id
  harness_platform_delegates = var.harness_platform_delegates
}

# Creates and Setup Harness connectors
# TODO: Add GCP, Azure and CCM connectors
module "bootstrap_harness_connectors" {
  depends_on = [
    module.bootstrap_harness_account
  ]
  source = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-connectors?ref=main"

  suffix                             = random_string.suffix.id
  tags                               = local.common_tags.tags
  delegate_selectors                 = local.delegate_selectors
  harness_platform_github_connectors = local.github_connectors

  harness_platform_docker_connectors = var.harness_platform_docker_connectors
  harness_platform_aws_connectors    = var.harness_platform_aws_connectors
  harness_platform_gcp_connectors    = var.harness_platform_gcp_connectors
}

# Creates Policies
module "bootstrap_harness_policies" {
  depends_on = [
    module.bootstrap_harness_account
  ]
  source = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-raw?ref=main"

  harness_platform_api_key = var.harness_platform_api_key
  harness_raw_request      = {}
}

# Creates Pipeline Templates
# TODO: Add Module
# ---

# # Creates Pipelines
module "bootstrap_harness_pipelines" {
  depends_on = [
    module.bootstrap_harness_account
  ]
  source = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-pipeline?ref=main"

  suffix                     = random_string.suffix.id
  tags                       = local.common_tags.tags
  harness_platform_pipelines = local.pipelines
}
