# org templates
locals {
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
