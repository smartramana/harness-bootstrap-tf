template:
  name: Terraform Plan Step
  identifier: terraform_plan_step
  versionLabel: 0.0.1
  type: Step
  orgIdentifier: ${org_identifier}
  tags: {}
  spec:
    timeout: 10m
    type: TerraformPlan
    spec:
      configuration:
        command: Apply
        configFiles:
          store:
            type: ${store_type_ref}
            spec:
              gitFetchType: Branch
              connectorRef: ${git_connector_ref}
              repoName: <+input>
              branch: <+input>
              folderPath: <+input>
        secretManagerRef: ${secret_manager_ref}
        backendConfig:
          type: Inline
          spec:
            content: |-
            %{ for key, value in tf_backend }
            ${key} = ${value}
            %{ endfor }
        varFiles:
          - varFile:
              identifier: vars
              spec:
                content: |-
                %{ for key, value in tf_variables }
                ${key} = ${value}
                %{ endfor }
              type: Inline
      provisionerIdentifier: ${provisioner_ref}
