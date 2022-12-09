harness_platform_account_id = "Io9SR1H7TtGBq9LVyJVB2w"
organization_prefix         = "cristian_lab_infrateam_org"

remote_state = {
  enable    = false
  backend   = "gcs"
  workspace = ""
  config = {
    bucket = "crizstian_terraform"
    prefix = ""
  }
}

harness_platform_organizations = {
  "cristian_lab_infrateam_org" = {
    enable       = true
    short_name   = "infrateam"
    description  = "Organization generated by terraform harness provider"
    tags         = ["owner: infrateam"]
    git_repo     = "harness-infrateam-tf"
    delegate_ref = "cristian_delegate_tf"
  }
}

harness_opa_policies = {}
