# Renders Pipeline
module "render_pipeline_template_files" {
  depends_on = [
    module.bootstrap_harness_account,
    module.bootstrap_harness_delegates,
    module.bootstrap_harness_connectors
  ]
  source            = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-templates?ref=main"
  harness_templates = local.pipeline_templates
}

# Loads Pipeline files in order to provision it with terraform
data "local_file" "pipeline_template" {
  depends_on = [
    module.render_pipeline_template_files
  ]
  for_each = local.pipeline_templates
  filename = module.render_pipeline_template_files.files[each.key]
}

# Creates Pipeline 
module "bootstrap_harness_pipelines" {
  depends_on = [
    data.local_file.pipeline_template
  ]
  source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-pipeline?ref=main"
  suffix                     = random_string.suffix.id
  harness_platform_pipelines = local.pipelines
}

output "pipelines" {
  value = module.bootstrap_harness_pipelines.pipelines
}
