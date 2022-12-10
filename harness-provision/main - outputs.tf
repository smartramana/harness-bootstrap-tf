# Outputs
output "harness" {
  value = merge(
    length(keys(module.bootstrap_harness_account.organization)) > 0 ? { organizations = module.bootstrap_harness_account.organization } : {},
    length(keys(module.bootstrap_harness_delegates.manifests)) > 0 ? { delegates = module.bootstrap_harness_delegates.manifests } : {},
    length(keys(module.bootstrap_harness_connectors.connectors)) > 0 ? { connectors = module.bootstrap_harness_connectors.connectors } : {},
    length(keys(module.bootstrap_harness_pipelines.pipelines)) > 0 ? { pipelines = module.bootstrap_harness_pipelines.pipelines } : {},
    length(keys(module.bootstrap_harness_pipelines.inputsets)) > 0 ? { inputsets = module.bootstrap_harness_pipelines.inputsets } : {}
  )
}


# output "policies" {
#   value = { for key, value in local.policies : key => { identifier = lookup(jsondecode(value.content), "identifier", "null") } }
# }
