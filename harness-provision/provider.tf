terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.7.1"
    }
  }

  backend "gcs" {}
}

provider "harness" {}

resource "random_string" "suffix" {
  length  = 4
  special = false
  lower   = true
}
