# OPA policies 
# locals {
#   policies_files = merge([for key, set in var.harness_opa_policies :
#     {
#       for policy, value in set.policies : policy => "${path.root}/${value.file}" if value.enable
#     } if set.enable
#   ]...)

#   policies = merge([for key, set in var.harness_opa_policies :
#     {
#       for policy, value in set.policies : policy =>
#       {
#         request_type = "POST"
#         content_type = "json"
#         endpoint     = set.level == "account" ? "${var.harness_policy_api_endpoint}?${local.account_args}" : "${var.harness_policy_api_endpoint}?${local.organization_args}"
#         content = jsonencode({
#           "identifier" : "${lower(replace(policy, "/[\\s-.]/", "_"))}_${random_string.suffix.id}",
#           "name" : set.level == "account" ? policy : "${var.organization_prefix}_${policy}",
#           "rego" : tostring(file("${path.root}/${value.file}")),
#         })
#       } if value.enable
#     } if set.enable
#   ]...)

#   policysets = { for key, value in var.harness_opa_policies : key => {

#     }
#   }
# }
