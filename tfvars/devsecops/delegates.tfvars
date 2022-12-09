# DELEGATES
harness_platform_delegates = {
  k8s = {
    "cristian_delegate_tf" = {
      enable           = true
      auto_install     = false
      create_connector = true
      #connector_id     = "account.cristian_delegate_tf_k8s_connector_ar6o"
      platform = "gcp"
      os       = "linux"
    }
    "devsecops_delegate_tf" = {
      enable           = true
      auto_install     = false
      create_connector = true
      platform         = "gcp"
      os               = "linux"
    }
  }
  docker = {
    "cristian_delegate_docker" = {
      enable       = false
      auto_install = false
      platform     = "aws"
      os           = "linux"
      connection = {
        user           = "ec2 user"
        host           = "ec2 ip address"
        private_key_id = "ec2 private key"
      }
    }
  }
}
