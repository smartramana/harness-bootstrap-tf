# seed pipeline
locals {
  seed_name                = "harness_seed_setup"
  seed_pipeline_definition = try(var.harness_platform_pipelines[local.seed_name], {})
  pipeline_seed_name       = "${local.seed_name}_${var.organization_prefix}"
  enable_seed_pipeline     = var.harness_platform_organizations[var.organization_prefix].enable && length(local.seed_pipeline_definition) > 0
  seed_pipeline_structure = {
    "${local.pipeline_seed_name}" = {
      pipeline = merge(
        local.seed_pipeline_definition.components.pipeline,
        {
          vars = merge(
            local.seed_pipeline_definition.components.pipeline.vars,
            local.common_schema,
            {
              tags              = concat(local.common_tags.tags, local.seed_pipeline_definition.components.pipeline.tags)
              delegate_ref      = local.delegate_ref
              k8s_connector_ref = local.k8s_connector_ref
              docker_ref        = local.docker_connector_ref
              git_connector_ref = local.github_connector_ref
              git_repo_ref      = var.harness_platform_organizations[var.organization_prefix].git_repo
              tf_backend_prefix = var.organization_prefix
            },
            [for stage, details in try(local.seed_pipeline_definition.components.pipeline.stages, {}) :
              {
                template_id      = try(module.bootstrap_harness_templates.templates[details.reference].identifier, "")
                template_version = try(details.version, "")
              } if try(details.template_stage, false)
            ]...
          )
        }
      )
      inputset = { for input, details in try(local.seed_pipeline_definition.components.inputset, {}) : input => details if details.enable }
      trigger  = { for t, details in try(local.seed_pipeline_definition.components.trigger, {}) : t => details if details.enable }
    }
  }
  seed_pipeline = local.enable_seed_pipeline ? local.seed_pipeline_structure : {}
}

# org pipelines
locals {
  _pipelines = { for pipe, values in var.harness_platform_pipelines : pipe => {
    pipeline = merge(
      values.components.pipeline,
      {
        vars = merge(
          values.components.pipeline.vars,
          local.common_schema,
          {
            tags              = concat(local.common_tags.tags, values.components.pipeline.tags)
            git_connector_ref = module.bootstrap_harness_connectors.connectors.github_connectors[values.components.pipeline.vars.git_connector].identifier
            service_ref       = module.bootstrap_harness_delegates.delegate_init.service_ref
            environment_ref   = module.bootstrap_harness_delegates.delegate_init.environment_ref
            k8s_connector_ref = local.k8s_connector_ref
            delegate_ref      = local.delegate_ref
          },
          [for stage, details in try(values.components.pipeline.stages, {}) :
            {
              template_id      = try(module.bootstrap_harness_templates.templates[stage].identifier, "")
              template_version = details.version
            } if try(details.template_stage, false)
          ]...
        )
      }
    )
    inputset = { for input, details in try(values.components.inputset, {}) : input => merge(
      details,
      {
        vars = merge(
          details.vars,
          {
            k8s_connector_ref = local.k8s_connector_ref
            delegate_ref      = local.delegate_ref
          }
      ) }
    ) if details.enable },
    trigger = { for t, details in try(values.components.trigger, {}) : t => details if details.enable }
    } if pipe != local.seed_name && values.components.pipeline.enable
  }
}

# pipelines
locals {
  pipelines = merge(local.seed_pipeline, local._pipelines)
}
