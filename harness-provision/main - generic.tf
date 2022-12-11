resource "random_string" "suffix" {
  length  = 4
  special = false
  lower   = true
}

data "terraform_remote_state" "remote" {
  count     = var.remote_state.enable ? 1 : 0
  backend   = var.remote_state.backend
  workspace = var.remote_state.workspace

  config = {
    bucket = var.remote_state.config.bucket
    prefix = var.remote_state.config.prefix
  }
}
