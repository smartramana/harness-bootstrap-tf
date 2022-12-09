# DELEGATES
harness_platform_delegates = {
  k8s = {
    "cristian_account_delegate_tf" = {
      enable           = true
      auto_install     = false
      create_connector = true
      platform         = "gcp"
      os               = "linux"
    }
  }
}
