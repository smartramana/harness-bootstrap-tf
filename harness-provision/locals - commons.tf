# common vars
locals {
  account_args            = "accountIdentifier=${var.harness_platform_account_id}"
  organization_args       = "${local.account_args}&orgIdentifier=${local.common_schema.org_id}"
  organization_short_name = var.harness_platform_organizations[var.organization_prefix].short_name
  common_tags = {
    tags = [
      "owner: ${var.organization_prefix}",
      "tf_workspace: ${terraform.workspace}"
    ]
  }
  common_schema = {
    org_id     = try(module.bootstrap_harness_account.organization[var.organization_prefix].org_id, "default")
    project_id = try(module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id, "")
    suffix     = try(module.bootstrap_harness_account.organization[var.organization_prefix].suffix, random_string.suffix.id)
  }
  remote_state = try(data.terraform_remote_state.remote.0.outputs.harness, {})
}
