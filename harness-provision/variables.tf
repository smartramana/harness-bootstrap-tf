# harness variables
variable "harness_platform_api_key" {
  type      = string
  sensitive = true
}
variable "harness_platform_account_id" {
  type = string
}
variable "harness_platform_organizations" {
  type    = map(any)
  default = {}
}
variable "harness_platform_delegates" {
  type    = any
  default = {}
}
variable "harness_platform_github_connectors" {
  #type    = map(any)
  default = {}
}
variable "harness_platform_docker_connectors" {
  type    = map(any)
  default = {}
}
variable "harness_platform_aws_connectors" {
  # type    = map(any)
  default = {}
}
variable "harness_platform_gcp_connectors" {
  # type    = map(any)
  default = {}
}
variable "harness_platform_pipelines" {
  #type    = map(any)
  default = {}
}
variable "harness_platform_inputsets" {
  type    = map(any)
  default = {}
}
variable "harness_opa_policies" {
  #type    = map(any)
  default = {}
}
variable "harness_policy_api_endpoint" {
  type    = string
  default = "https://app.harness.io/gateway/pm/api/v1/policies"
}
variable "harness_policyset_api_endpoint" {
  type    = string
  default = "https://app.harness.io/gateway/pm/api/v1/policies"
}
# other variables
variable "organization_prefix" {
  type    = string
  default = ""
}
variable "remote_state" {
  # type    = map(any)
  default = {
    enable    = false
    backend   = ""
    workspace = ""
    config = {
      bucket = ""
      prefix = ""
    }
  }
}
