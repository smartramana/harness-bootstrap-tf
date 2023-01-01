# org templates
locals {
  templates             = { for key, values in var.harness_platform_templates : key => values if values.enable }
  templates_account_ref = var.remote_state.enable ? local.remote_state.templates : {}
  module_templates      = module.bootstrap_harness_templates.templates
}
