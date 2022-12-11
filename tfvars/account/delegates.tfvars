# DELEGATES
harness_platform_delegates = {
  k8s = {
    "cristian-account-delegate-tf" = {
      enable           = true
      auto_install     = false
      create_connector = true
      platform         = "gcp"
      os               = "linux"
    }
  }
}
