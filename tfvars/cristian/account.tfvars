harness_platform_account_id = "Io9SR1H7TtGBq9LVyJVB2w"

organization_prefix = "cristian-lab-devsecops-org"

harness_platform_organizations = {
  "cristian-lab-devsecops-org" = {
    enable      = true
    description = "Organization generated by terraform harness provider"
  }
}

#delegate_prefix = "cristian-delegate-tf"
harness_platform_delegates = {
  k8s = {
    "cristian-delegate-tf" = {
      enable                 = true
      description            = "Delegate deployed and generated by terraform harness provider"
      size                   = "SMALL"
      tags                   = ["cristian-delegate-tf"]
      clusterPermissionType  = "CLUSTER_ADMIN"
      customClusterNamespace = "harness-delegate-ng"
    }
  }
}

harness_platform_github_connectors = {
  devsecops_connector = {
    enable          = true
    description     = "Connector generated by terraform harness provider"
    connection_type = "Repo"
    url             = "https://github.com/crizstian/harness-bootstrap-tf"
    credentials = {
      http = {
        username     = "crizstian"
        token_ref_id = "account.crizstian_github_token"
      }
    }
    api_authentication = {
      token_ref_id = "account.crizstian_github_token"
    }
  }
}
