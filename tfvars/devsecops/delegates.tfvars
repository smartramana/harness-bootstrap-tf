# DELEGATES
harness_platform_delegates = {
  k8s = {
    "cristian-delegate-tf" = {
      enable           = true
      auto_install     = true
      create_connector = false
      connector_id     = "account.cristian_delegate_tf_k8s_connector_ar6o"
      platform         = "gcp"
      os               = "linux"
    }
  }
  docker = {
    "cristian-delegate-docker" = {
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
