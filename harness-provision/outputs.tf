# Outputs
output "organizations" {
  value = module.bootstrap_harness_account.organization
}
output "delegates" {
  value = module.bootstrap_harness_delegates.manifests
}
output "connectors" {
  value = module.bootstrap_harness_connectors.connectors
}
output "pipelines" {
  value = module.bootstrap_harness_pipelines.pipelines
}
output "inputsets" {
  value = module.bootstrap_harness_pipelines.inputsets
}
# output "policies" {
#   value = { for key, value in local.policies : key => { identifier = lookup(jsondecode(value.content), "identifier", "null") } }
# }

