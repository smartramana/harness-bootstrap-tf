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

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

output "details" {
  value = {
    organization = module.bootstrap_harness_account.organization
    delegates    = module.bootstrap_harness_delegates.delegates
  }
}
