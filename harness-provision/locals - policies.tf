# OPA policies 
locals {
  policies = { for key, values in var.harness_platform_policies : key => value if values.enable }
}
