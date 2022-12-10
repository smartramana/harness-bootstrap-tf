# DELEGATES
harness_platform_delegates = {
  k8s = {
    "cristian_delegate_tf" = {
      enable           = true
      auto_install     = false
      create_connector = false
      connector_id     = "account.cristian_delegate_tf_k8s_connector_ar6o"
      platform         = "gcp"
      os               = "linux"
    }
  }
  docker = {}
}
