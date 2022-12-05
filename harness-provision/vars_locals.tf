# common vars
locals {
  git_suffix        = "_github_connector"
  docker_suffix     = "_docker_connector"
  account_args      = "accountIdentifier=${var.harness_platform_account_id}"
  organization_args = "accountIdentifier=${var.harness_platform_account_id}&orgIdentifier=${local.common_schema.org_id}"
  common_tags       = { tags = ["owner: ${var.organization_prefix}"] }
  common_schema = {
    org_id     = module.bootstrap_harness_account.organization[var.organization_prefix].org_id
    project_id = module.bootstrap_harness_account.organization[var.organization_prefix].seed_project_id
    suffix     = module.bootstrap_harness_account.organization[var.organization_prefix].suffix
  }
}

# github connectors
locals {
  github_connectors = { for key, value in var.harness_platform_github_connectors : key => merge(value, {
    org_id     = can(value.org_id) ? module.bootstrap_harness_account.organization[value.org_id].org_id : ""
    project_id = can(value.project_id) ? module.bootstrap_harness_account.organization[value.org_id].seed_project_id : ""
  }) }
}

# seed pipeline
locals {
  seed_pipeline = var.harness_platform_pipelines["harness_seed_setup"]

  seed_pipe = { for org, values in var.harness_platform_organizations : "harness_seed_setup_${values.short_name}" => {
    pipeline = merge(
      { for key, value in local.seed_pipeline : key => value if key != "custom_template" },
      local.seed_pipeline.custom_template.pipeline,
      {
        vars = merge(
          local.seed_pipeline.custom_template.pipeline.vars,
          {
            org_id                  = module.bootstrap_harness_account.organization[org].org_id
            project_id              = module.bootstrap_harness_account.organization[org].seed_project_id
            suffix                  = module.bootstrap_harness_account.organization[org].suffix
            tf_provision_identifier = "tf_${org}"
            tf_backend_prefix       = org
            git_connector_ref       = module.bootstrap_harness_connectors.connectors.github_connectors["${values.short_name}${local.git_suffix}"].identifier
            docker_ref              = module.bootstrap_harness_connectors.connectors.docker_connectors["${values.short_name}${local.docker_suffix}"].identifier
            k8s_connector_ref       = module.bootstrap_harness_delegates.manifests["default"][values.delegate_ref].k8s_connector.identifier
            delegate_ref            = values.delegate_ref
            git_repo_ref            = values.git_repo
          }
        )
    })
    inputset = { for input, details in try(local.seed_pipeline.custom_template.inputset, {}) : input => merge(details) if details.enable }
    }
  }
}

# devsecops pipelines
locals {
  devsecops_pipelines = { for pipe, values in var.harness_platform_pipelines : pipe => {
    pipeline = merge(
      { for key, value in values : key => value if key != "custom_template" },
      values.custom_template.pipeline,
      {
        vars = merge(
          values.custom_template.pipeline.vars,
          local.common_schema,
          {
            git_connector_ref = module.bootstrap_harness_connectors.connectors.github_connectors["${values.custom_template.pipeline.vars.git_connector}${local.git_suffix}"].identifier
            service_ref       = module.bootstrap_harness_delegates.delegate_init.service_ref
            environment_ref   = module.bootstrap_harness_delegates.delegate_init.environment_ref
          }
        )
      }
    )
    inputset = { for input, details in try(values.custom_template.inputset, {}) : input => merge(details) if details.enable }
    } if pipe != "harness_seed_setup"
  }
}

# pipelines
locals {
  pipelines = merge(local.seed_pipe, local.devsecops_pipelines)
}

# OPA policies 
# locals {
#   policies_files = merge([for key, set in var.harness_opa_policies :
#     {
#       for policy, value in set.policies : policy => "${path.root}/${value.file}" if value.enable
#     } if set.enable
#   ]...)

#   policies = merge([for key, set in var.harness_opa_policies :
#     {
#       for policy, value in set.policies : policy =>
#       {
#         request_type = "POST"
#         content_type = "json"
#         endpoint     = set.level == "account" ? "${var.harness_policy_api_endpoint}?${local.account_args}" : "${var.harness_policy_api_endpoint}?${local.organization_args}"
#         content = jsonencode({
#           "identifier" : "${lower(replace(policy, "/[\\s-.]/", "_"))}_${random_string.suffix.id}",
#           "name" : set.level == "account" ? policy : "${var.organization_prefix}_${policy}",
#           "rego" : tostring(file("${path.root}/${value.file}")),
#         })
#       } if value.enable
#     } if set.enable
#   ]...)

#   policysets = { for key, value in var.harness_opa_policies : key => {

#     }
#   }
# }
