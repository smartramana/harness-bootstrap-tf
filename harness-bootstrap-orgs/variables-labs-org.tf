locals {
  cristian-lab-org = "cristian-lab-org"

  cristian_lab_organizations = {
    "${local.cristian-lab-org}" = {
      enable      = true
      description = "Organization generated by terraform harness provider"
    }
  }
}
