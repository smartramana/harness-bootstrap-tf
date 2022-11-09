inputSet:
  identifier: ${name}_${suffix}
  name: ${name}
  tags: {}
  projectIdentifier: ${project_id}
  orgIdentifier: ${org_id}
  pipeline:
    identifier: ${pipeline_id}
    stages:
    - stage:
        identifier: Provisioning
        type: Custom
        variables:
        - name: tf_provision_identifier
          type: String
          value: ${tf_provision_identifier}
        - name: tf_branch
          type: String
          value: <+trigger.sourceBranch>
        - name: tf_folder
          type: String
          value: ${tf_folder}
        - name: tf_workspace
          type: String
          value: ${tf_workspace}
        - name: tf_account_vars
          type: String
          value: ${tf_account_vars}
        - name: tf_connectors_vars
          type: String
          value: ${tf_connectors_vars}
        - name: tf_delegates_vars
          type: String
          value: ${tf_delegates_vars}
        - name: tf_pipelines_vars
          type: String
          value: ${tf_pipelines_vars}
        - name: tf_backend_bucket
          type: String
          value: ${tf_backend_bucket}
        - name: tf_backend_prefix
          type: String
          value: ${tf_backend_prefix}
        - name: tf_action
          type: String
          value: apply