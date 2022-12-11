# seed pipeline
locals {
  seed_name            = "harness_seed_setup"
  seed_structure       = try(var.harness_platform_pipelines[local.seed_name], {})
  pipeline_seed_name   = "${local.seed_name}_${var.organization_prefix}"
  enable_seed_pipeline = var.harness_platform_organizations[var.organization_prefix].enable

  seed_pipeline = local.enable_seed_pipeline ? {
    "${local.pipeline_seed_name}" = {
      pipeline = merge(
        { for key, value in local.seed_structure : key => value if key != "custom_template" },
        local.seed_structure.custom_template.pipeline,
        {
          vars = merge(
            local.seed_structure.custom_template.pipeline.vars,
            local.common_schema,
            {
              tags              = concat(local.common_tags.tags, local.seed_structure.tags)
              identifier        = "${local.pipeline_seed_name}_${random_string.suffix.id}"
              delegate_ref      = local.delegate_ref
              k8s_connector_ref = local.k8s_connector_ref
              docker_ref        = local.docker_connector_ref
              git_connector_ref = local.github_connector_ref
              git_repo_ref      = var.harness_platform_organizations[var.organization_prefix].git_repo
              tf_backend_prefix = var.organization_prefix
            }
          )
      })
      inputset = { for input, details in try(local.seed_structure.custom_template.inputset, {}) : input => details if details.enable }
      trigger  = { for t, details in try(local.seed_structure.custom_template.trigger, {}) : t => details if details.enable }
    }
  } : {}
}

# org pipelines
locals {
  _pipelines = { for pipe, values in var.harness_platform_pipelines : pipe => {
    pipeline = merge(
      { for key, value in values : key => value if key != "custom_template" },
      values.custom_template.pipeline,
      {
        vars = merge(
          values.custom_template.pipeline.vars,
          local.common_schema,
          {
            tags              = concat(local.common_tags.tags, local.seed_structure.tags)
            git_connector_ref = module.bootstrap_harness_connectors.connectors.github_connectors[values.custom_template.pipeline.vars.git_connector].identifier
            service_ref       = module.bootstrap_harness_delegates.delegate_init.service_ref
            environment_ref   = module.bootstrap_harness_delegates.delegate_init.environment_ref
          }
        )
      }
    )
    inputset = { for input, details in try(values.custom_template.inputset, {}) : input => details if details.enable },
    trigger  = { for t, details in try(values.custom_template.trigger, {}) : t => details if details.enable }
    } if pipe != local.seed_name
  }
}

# pipelines
locals {
  pipelines = merge(local.seed_pipeline, local._pipelines)
}
