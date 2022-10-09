# # Renders InputSet files in order to provision it with terraform
# module "render_inputset_template_files" {
#   depends_on = [
#     module.bootstrap_harness_pipelines
#   ]
#   source            = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-templates?ref=main"
#   harness_templates = local.inputset_templates
# }

# # Loads InputSet files in order to provision it with terraform
# data "local_file" "inputset_template" {
#   depends_on = [
#     module.render_inputset_template_files
#   ]
#   for_each = local.inputset_templates
#   filename = module.render_inputset_template_files.files[each.key]
# }

# # Creates InputSet 
# module "bootstrap_harness_inputsets" {
#   depends_on = [
#     data.local_file.inputset_template
#   ]
#   source                     = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-pipeline?ref=main"
#   suffix                     = random_string.suffix.id
#   harness_platform_inputsets = local.inputsets
# }

# output "inputsets" {
#   value = module.bootstrap_harness_inputsets.inputsets
# }
