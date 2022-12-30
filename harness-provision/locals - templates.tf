# org templates
locals {
  templates_account_ref = var.remote_state.enable ? local.remote_state.templates : {}
  templates = { for key, values in var.harness_platform_templates : key => merge(
    values,
    {
      vars = merge(
        values.vars
      )
    }
    ) if values.enable
  }
}
