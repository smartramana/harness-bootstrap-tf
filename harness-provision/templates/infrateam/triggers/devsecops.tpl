trigger:
  name: ${name}
  identifier: ${identifier}
  enabled: ${enabled}
  encryptedWebhookSecretIdentifier: ""
  description: ${description}
  tags: {}
  orgIdentifier: ${org_id}
  projectIdentifier: ${project_id}
  pipelineIdentifier: ${pipeline_id}
  source:
    type: Webhook
    spec:
      type: Github
      spec:
        type: PullRequest
        spec:
          connectorRef: ${git_connector_ref}
          autoAbortPreviousExecutions: true
          payloadConditions: []
          headerConditions: []
          actions:
            - Open
            - Reopen
            - Synchronize
  inputYaml: |
    pipeline:
      identifier: ${pipeline_id}
      stages:
        - stage:
            identifier: Terraform_STO
            template:
              templateInputs:
                type: CI
                variables:
                  - name: k8s_connector_ref
                    type: String
                    value: ${k8s_connector_ref}
                  - name: docker_connector_ref
                    type: String
                    value: ${docker_connector_ref}
        - stage:
            identifier: Provisioning
            type: Custom
            variables:
              - name: tf_branch
                type: String
                value: <+trigger.sourceBranch>
              - name: tf_folder
                type: String
                value: ${tf_folder}
              - name: tf_workspace
                type: String
                value: <+trigger.sourceBranch>
              - name: tf_backend_bucket
                type: String
                value: ${tf_backend_bucket}
              - name: tf_backend_prefix
                type: String
                value: ${tf_backend_prefix}
              - name: tf_action
                type: String
                value: apply
      properties:
        ci:
          codebase:
            build:
              type: branch
              spec:
                branch: <+trigger.sourceBranch>