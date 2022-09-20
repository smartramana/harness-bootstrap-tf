module "bootstrap_harness_account" {
  source                    = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  harness_platform_projects = local.harness_platform_projects

  providers = {
    harness = harness.provisioner
  }
}

module "bootstrap_harness_connector" {
  depends_on = [
    module.bootstrap_harness_account,
    # module.bootstrap_harness_delegates
  ]
  source                      = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-connectors?ref=main"
  harness_platform_connectors = local.harness_platform_connectors

  providers = {
    harness = harness.provisioner
  }
}

resource "harness_platform_secret_text" "harness_secrets" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  for_each                  = local.harness_platform_secrets
  identifier                = "${lower(replace(each.key, "/[\\s-.]/", "_"))}_1"
  name                      = each.key
  description               = "${each.key} - ${each.value.description}"
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = each.value.secret
  org_id                    = each.value.org_id

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

module "bootstrap_harness_templates" {
  depends_on = [
    module.bootstrap_harness_account,
  ]
  source                                 = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-templates?ref=main"
  harness_platform_api_key               = var.harness_platform_api_key
  harness_templates                      = local.harness_templates
  harness_template_endpoint_account_args = local.harness_template_endpoint_account_args
}

# module "bootstrap_harness_delegates" {
#   depends_on = [
#     module.bootstrap_harness_account,
#   ]
#   source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-delegate?ref=main"
#   harness_platform_delegates = local.harness_platform_delegates
#   harness_platform_api_key   = var.harness_platform_api_key
#   harness_account_id         = var.harness_platform_account_id
# }

output "details" {
  value = {
    organization = module.bootstrap_harness_account.organization
    # delegates    = module.bootstrap_harness_delegates.delegates
    project = module.bootstrap_harness_account.project
    # manifests  = module.bootstrap_harness_delegates.manifests
    connectors = module.bootstrap_harness_connector.connectors
  }
}
