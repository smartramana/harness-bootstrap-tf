locals {
  harness_templates = {
    tf_pipeline = {
      update_endpoint = "/update/Terraform/0.0.1${local.harness_template_endpoint_account_args}"
      file            = "../contrib/harness/templates/terraform-pipeline.tpl"
      vars = {
        org_identifier     = module.bootstrap_harness_account.organization[var.cristian_lab_org_projects.organization_name].org_id
        git_connector_ref  = "org.crizstian_lab_github_connector" # TODO: get name dynamically
        secret_manager_ref = "org.harnessSecretManager"
        approver_ref       = "account.SE_Admin" # TODO: get name dynamically
        delegate_ref       = "cr-tf"            # TODO: get name dynamically
        store_type_ref     = "Github"
        provisioner_ref    = "<+pipeline.stages.[\"Provisioning\"].variables.[\"provisioner_ref\"]>"
        version            = "0.0.1"

        tf_backend = {
          username = "<+pipeline.stages.[\"Provisioning\"].variables.[\"tf_backend_username\"]>"
          password = "<+pipeline.stages.[\"Provisioning\"].variables.[\"tf_backend_password\"]>"
          url      = "<+pipeline.stages.[\"Provisioning\"].variables.[\"tf_backend_url\"]>"
          repo     = "<+pipeline.stages.[\"Provisioning\"].variables.[\"tf_backend_repo\"]>"
          subpath  = "<+pipeline.stages.[\"Provisioning\"].variables.[\"tf_backend_subpath\"]>"
        }
        tf_variables = {
          harness_platform_api_key    = "<+pipeline.stages.[\"Provisioning\"].variables.[\"harness_platform_api_key\"]>"
          harness_platform_account_id = "<+pipeline.stages.[\"Provisioning\"].variables.[\"harness_platform_account_id\"]>"
          # connector_crizstian_github_token      = "<+secrets.getValue(\"connector_crizstian_github_token\")>"
          # connector_crizstian_docker_token      = "<+secrets.getValue(\"connector_crizstian_docker_token\")>"
          # connector_crizstian_artifactory_token = "<+secrets.getValue(\"connector_crizstian_artifactory_token\")>"
        }
      }
    }
  }
}
