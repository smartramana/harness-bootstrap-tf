template:
  name: Terraform
  identifier: Terraform
  versionLabel: ${version}
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
                                    branch: <+stage.variables.git_branch>
                                    folderPath: <+stage.variables.git_folderPath>
                                    repoName: <+stage.variables.git_repoName>
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
                            provisionerIdentifier: <+stage.variables.harness_provisioner_identifier>
                            delegateSelectors:
                              - ${delegate_ref}
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
                                provisionerIdentifier: <+stage.variables.harness_provisioner_identifier>
                                delegateSelectors:
                                  - ${delegate_ref}
                              timeout: 10m
                              when:
                                stageStatus: Success
                                condition: <+stage.variable.tf_action> == "apply"
                              failureStrategies: []
                          - step:
                              type: TerraformDestroy
                              name: TF Destroy
                              identifier: TF_Destroy
                              spec:
                                provisionerIdentifier: <+stage.variables.harness_provisioner_identifier>
                                delegateSelectors:
                                  - ${delegate_ref}
                                configuration:
                                  type: InheritFromApply
                              timeout: 10m
                              when:
                                stageStatus: Success
                                condition: <+stage.variable.tf_action> == "destroy"
                              failureStrategies: []
                    failureStrategies: []
                    delegateSelectors:
                      - ${delegate_ref}
              rollbackSteps: []
            serviceDependencies: []
          tags: {}
          variables:
            - name: git_repoName
              type: String
              value: <+input>
            - name: git_branch
              type: String
              value: <+input>
            - name: git_folderPath
              type: String
              value: <+input>
            - name: harness_provisioner_identifier
              type: String
              value: <+input>
            - name: harness_platform_api_key
              type: String
              value: <+input>
            - name: harness_platform_account_id
              type: String
              value: <+input>
            - name: tf_action
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
