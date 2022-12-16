terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }

  backend "gcs" {}
}

provider "harness" {}
