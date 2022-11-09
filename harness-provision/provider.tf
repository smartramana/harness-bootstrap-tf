terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }

  backend "gcs" {}
}

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = var.harness_platform_account_id
  platform_api_key = var.harness_platform_api_key
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  lower   = true
}
