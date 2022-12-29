harness_platform_templates = {
  terraform_sto_stage = {
    enable      = true
    description = "Template generated by terraform harness provider"
    tags        = ["type: terraform-security"]
    file        = "templates/stages/terraform_sto.tpl"
    vars = {
      comments  = "terraform sto stage"
      version   = "beta"
      is_stable = true
    }
  }
}
