module "bootstrap_project" {
  source                    = "git::https://github.com/crizstian/harness-terraform-modules.git//harness-project?ref=main"
  harness_platform_projects = var.harness_platform_projects

  providers = {
    harness = harness.provisioner
  }
}

output "details" {
  value = {
    project = module.bootstrap_project.project
  }
}
