# Create Organizations
module "bootstrap_harness_account" {
  source                         = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  suffix                         = random_string.suffix.id
  harness_platform_organizations = var.harness_platform_organizations
}

# Creates and uploads delegates manifests to Harness FileStore: => Account/Org/File
# TODO: Auto Install delegates
module "bootstrap_harness_delegates" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-delegate?ref=main"
  suffix = random_string.suffix.id

  harness_platform_delegates = local.delegates
  harness_platform_api_key   = var.harness_platform_api_key
  harness_account_id         = var.harness_platform_account_id
  harness_organization       = module.bootstrap_harness_account.organization[var.organization_prefix]

  enable_delegate_init_service = true
}

# Creates and Setup Harness connectors
# TODO: Add GCP, Azure and CCM connectors
module "bootstrap_harness_connectors" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                             = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-connectors?ref=main"
  suffix                             = random_string.suffix.id
  harness_platform_github_connectors = local.github_connectors
  harness_platform_k8s_connectors    = local.k8s_connectors
  harness_platform_docker_connectors = local.docker_connectors
  harness_platform_aws_connectors    = local.aws_connectors
  harness_platform_gcp_connectors    = local.aws_connectors
}

# Creates Policies
module "bootstrap_harness_policies" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                   = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-raw?ref=main"
  harness_raw_request      = {}
  harness_platform_api_key = var.harness_platform_api_key
}

# Creates Pipeline Templates
# TODO: Add Module
# ---

# # Creates Pipelines
module "bootstrap_harness_pipelines" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-pipeline?ref=main"
  suffix                     = random_string.suffix.id
  harness_platform_pipelines = local.pipelines
}
