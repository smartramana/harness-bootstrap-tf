terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }

  backend "gcs" {}
}

provider "harness" {}
