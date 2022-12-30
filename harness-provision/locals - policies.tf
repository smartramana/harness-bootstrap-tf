# OPA policies 
locals {
  policies = { for key, values in var.harness_opa_policies : key => values if values.enable }
}
