resource "harness_platform_secret_text" "harness_secrets" {
  for_each                  = local.harness_platform_secrets
  identifier                = lower(replace(each.key, "/[\\s-.]/", "_"))
  name                      = each.key
  description               = each.value.description
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
