# common vars
locals {
  delegate_init_service = length(var.harness_platform_delegates) > 0 ? {
    enable     = local.enable_seed_pipeline
    org_id     = local.common_schema.org_id
    project_id = local.common_schema.project_id
    } : {
    enable     = false
    org_id     = ""
    project_id = ""
  }
}
