template:
  name: Terraform
  identifier: Terraform
  versionLabel: 0.0.1
  type: Pipeline
  orgIdentifier: ${org_identifier}
  tags: {}
  spec:
    stages:
      - stage:
          name: Provisioning
          identifier: Provisioning
          description: ""
          type: Custom
          spec:
            execution:
              steps:
                - stepGroup:
                    name: Terraform Plan and Apply-Destroy
                    identifier: Terraform_Plan_and_ApplyDestroy
                    steps:
                      - step:
                          type: TerraformPlan
                          name: TF Plan
                          identifier: TF_Plan
                          spec:
                            configuration:
                              command: Apply
                              configFiles:
                                store:
                                  type: Github
                                  spec:
                                    gitFetchType: Branch
                                    connectorRef: ${git_connector_ref}
                                    repoName: <+pipeline.stages.["Provisioning"].variables.["git_repoName"]>
                                    branch: <+pipeline.stages.["Provisioning"].variables.["git_branch"]>
                                    folderPath: <+pipeline.stages.["Provisioning"].variables.["git_folderPath"]>
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
                            provisionerIdentifier: <+pipeline.stages.["Provisioning"].variables.["provisioner_identifier"]>
                          timeout: 10m
                      - step:
                          type: HarnessApproval
                          name: Approve
                          identifier: Approve
                          spec:
                            approvalMessage: Please review the following information and approve the pipeline progression
                            includePipelineExecutionHistory: true
                            approvers:
                              userGroups:
                                - ${approver_ref}
                              minimumCount: 1
                              disallowPipelineExecutor: false
                            approverInputs: []
                          timeout: 1d
                      - parallel:
                          - step:
                              type: TerraformApply
                              name: TF Apply
                              identifier: TF_Apply
                              spec:
                                configuration:
                                  type: InheritFromPlan
                                provisionerIdentifier: tf
                              timeout: 10m
                              when:
                                stageStatus: Success
                                condition: <+stage.variable.action> == "apply"
                              failureStrategies: []
                          - step:
                              type: TerraformDestroy
                              name: TF Destroy
                              identifier: TF_Destroy
                              spec:
                                provisionerIdentifier: tf
                                configuration:
                                  type: InheritFromApply
                              timeout: 10m
                              when:
                                stageStatus: Success
                                condition: <+stage.variable.action> == "destroy"
                              failureStrategies: []
                    failureStrategies: []
                    delegateSelectors:
                      - ${delegate_ref}
              rollbackSteps: []
            serviceDependencies: []
          tags: {}
          variables:
            - name: action
              type: String
              value: <+input>
            - name: repoName
              type: String
              value: <+input>
            - name: branch
              type: String
              value: <+input>
            - name: folderPath
              type: String
              value: <+input>
            - name: provisioner_identifier
              type: String
              value: <+input>
            - name: tf_backend_username
              type: String
              value: <+input>
            - name: tf_backend_password
              type: String
              value: <+input>
            - name: tf_backend_url
              type: String
              value: <+input>
            - name: tf_backend_repo
              type: String
              value: <+input>
            - name: tf_backend_subpath
              type: String
              value: <+input>
            - name: harness_platform_api_key
              type: String
              value: <+input>
            - name: harness_platform_account_id
              type: String
              value: <+input>
