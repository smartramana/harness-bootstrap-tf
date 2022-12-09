# GITHUB CONNECTORS
harness_platform_github_connectors = {
  infrateam = {
    id              = "account.infrateam_github_connector_ar6o"
    enable          = false
    description     = "Connector generated by terraform harness provider"
    connection_type = "Repo"
    url             = "https://github.com/crizstian/harness-infrateam-tf"
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

# DOCKER CONNECTORS
harness_platform_docker_connectors = {
  infrateam = {
    enable             = true
    description        = "Connector generated by terraform harness provider"
    type               = "DockerHub"
    url                = "https://index.docker.io/v2/"
    delegate_selectors = ["cristian-delegate-tf"]
    credentials = {
      username        = "crizstian"
      password_ref_id = "account.crizstian_docker_token"
    }
  }
}
