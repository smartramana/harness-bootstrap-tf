pipeline:
  name: ${name}
  identifier: ${identifier}
  projectIdentifier: ${project_id}
  orgIdentifier: ${org_id}
  tags: {}
  stages:
    - stage:
        name: Terraform Scan
        identifier: Terraform_Validation
        type: CI
        spec:
          cloneCodebase: true
          infrastructure:
            type: KubernetesDirect
            spec:
              connectorRef: ${k8s_connector_ref}
              namespace: harness-delegate-ng
              automountServiceAccountToken: true
              nodeSelector: {}
              os: Linux
          execution:
            steps:
              - stepGroup:
                  name: Terraform Scan
                  identifier: Terraform_Scan
                  steps:
                    - parallel:
                        - step:
                            type: Run
                            name: AquaSec
                            identifier: aquasecurity_tfsec
                            spec:
                              connectorRef: ${docker_ref}
                              image: aquasec/tfsec-alpine
                              shell: Sh
                              command: |-
                                ls -la

                                tfsec /harness
                        - step:
                            type: Run
                            name: Checkov
                            identifier: Checkov
                            spec:
                              connectorRef: ${docker_ref}
                              image: bridgecrew/checkov
                              shell: Sh
                              command: |
                                checkov --skip-path tfscan.json --output json --compact --output-file-path checkov -d .
                              privileged: false
                            failureStrategies:
                              - onFailure:
                                  errors:
                                    - AllErrors
                                  action:
                                    type: Ignore
                        - step:
                            type: Run
                            name: Terrascan
                            identifier: Terrascan
                            spec:
                              connectorRef: ${docker_ref}
                              image: tenable/terrascan
                              shell: Sh
                              command: terrascan scan -o json > tfscan.json
                            failureStrategies:
                              - onFailure:
                                  errors:
                                    - AllErrors
                                  action:
                                    type: Ignore
              - stepGroup:
                  name: STO Process
                  identifier: STO_Process
                  steps:
                    - parallel:
                        - step:
                            type: Run
                            name: Checkov Ingest
                            identifier: Checkov_Ingest
                            spec:
                              connectorRef: ${docker_ref}
                              image: ubuntu
                              shell: Sh
                              command: |+
                                apt-get update
                                apt-get install -y jq

                                ls -la

                                ls -la checkov

                                arr="[]"
                                i=0
                                jq -c '.[]' checkov/results_json.json | while read f; do

                                    for row in $(echo "$f" | jq -r '.results.failed_checks[] | @base64'); do

                                        id=$(echo "$row" | base64 --decode | jq .check_id | sed 's/\"//g')
                                        bc_id=$(echo "$row" | base64 --decode | jq .bc_check_id | sed 's/\"//g')
                                        issueName=$(echo "$row" | base64 --decode | jq .check_name | sed 's/\"//g')
                                        issueDescription=$(echo "$row" | base64 --decode | jq .description | sed 's/\"//g')
                                        fileName=$(echo "$row" | base64 --decode | jq .file_path | sed 's/\"//g')
                                        remediationSteps=$(echo "$row" | base64 --decode | jq .check_class | sed 's/\"//g')
                                        risk=$(echo "$row" | base64 --decode | jq .guideline | sed 's/\"//g')
                                        severity=5
                                        status=$(echo "$row" | base64 --decode | jq .check_result.result | sed 's/\"//g')
                                        cvss=$(echo "$row" | base64 --decode | jq .check_id | sed 's/\"//g')
                                        
                                        issueType=$(echo $f | jq .check_type | sed 's/\"//g') 
                                        lineNumber=$(echo "$row" | base64 --decode | jq .file_line_range[0] | sed 's/\"//g')
                                        product=$(echo "$row" | base64 --decode | jq .resource | sed 's/\"//g')

                                        element=$(jq -n '{scanTool: $scanTool,issueName: $issueName,issueDescription: $issueDescription,fileName: $fileName,remediationSteps: $remediationSteps,risk: $risk,severity: $severity|tonumber,status: $status,issueType: $issueType,lineNumber: $lineNumber,product: $product,referenceIdentifiers: $referenceIdentifiers}' \
                                            --arg scanTool "checkov" \
                                            --arg issueName "$issueName" \
                                            --arg issueDescription "$issueDescription" \
                                            --arg fileName "$fileName" \
                                            --arg remediationSteps "$remediationSteps" \
                                            --arg risk $risk" "\
                                            --arg severity $severity \
                                            --arg status "$status" \
                                            --arg issueType "$issueType" \
                                            --arg lineNumber "$lineNumber" \
                                            --arg product "$product" \
                                            --argjson referenceIdentifiers "[{\"type\":\"CKV\", \"id\":"$i"}]" \
                                            '$ARGS.named'
                                        )

                                        a=$(jq -n \
                                            --argjson temp "[$element]" \
                                            --argjson issues "$arr" \
                                            '$ARGS.named'
                                        )
                                        
                                        # echo $a | jq '.'

                                        arr=$(echo $a | jq '.temp + .issues')

                                        echo $arr | jq . > issues.json

                                        i=$(( $i + 1 ))
                                    done

                                done

                                issues=$(cat issues.json | jq '.')

                                jq -n \
                                    --argjson meta "{ \"key\":[\"issueName\"], \"author\":\"Checkov\" }" \
                                    --argjson issues "$issues" \
                                    '$ARGS.named' \
                                    > checkov.json

                                cat checkov.json | jq .

                                cp checkov.json /shared/customer_artifacts

                            failureStrategies:
                              - onFailure:
                                  errors:
                                    - Timeout
                                  action:
                                    type: Ignore
                            timeout: 5m
                        - step:
                            type: Run
                            name: Terrascan Ingest
                            identifier: Terrascan_Ingest
                            spec:
                              connectorRef: ${docker_ref}
                              image: alpine
                              shell: Sh
                              command: |+
                                apk add jq

                                cat tfscan.json

                                arr="[]"
                                # 
                                i=1
                                jq -c '.results.violations[]' tfscan.json | while read f; do

                                    s=5
                                    sev=$(echo $f | jq .severity | sed 's/\"//g')

                                    if [ "$sev" = "LOW" ]; then
                                        s=3
                                    elif [ "$sev" = "MEDIUM" ]; then
                                        s=5
                                    elif [ "$sev" = "HIGH" ]; then
                                        s=10
                                    fi
                                        # echo "$row" | base64 --decode | jq .check_id

                                        id=$(echo $f | jq .rule_id | sed 's/\"//g')
                                        issueName=$(echo $f | jq .rule_name | sed 's/\"//g')
                                        issueDescription=$(echo $f | jq .description | sed 's/\"//g')
                                        fileName=$(echo $f | jq .file | sed 's/\"//g')
                                        remediationSteps=$(echo $f | jq .category | sed 's/\"//g')
                                        risk=$(echo $f | jq .severity | sed 's/\"//g')
                                        severity=$s
                                        status=$(echo $f | jq .severity | sed 's/\"//g')
                                        cvss=$(echo $f | jq .rule_id | sed 's/\"//g')
                                        
                                        issueType=$(echo $f | jq .resource_name | sed 's/\"//g')
                                        lineNumber=$(echo $f | jq .line | sed 's/\"//g')
                                        product=$(echo $f | jq .resource_type | sed 's/\"//g')

                                        element=$(jq -n '{scanTool: $scanTool,issueName: $issueName,issueDescription: $issueDescription,fileName: $fileName,remediationSteps: $remediationSteps,risk: $risk,severity: $severity|tonumber,status: $status,issueType: $issueType,lineNumber: $lineNumber,product: $product,referenceIdentifiers: $referenceIdentifiers}' \
                                            --arg scanTool "terrascan" \
                                            --arg issueName "$issueName" \
                                            --arg issueDescription "$issueDescription" \
                                            --arg fileName "$fileName" \
                                            --arg remediationSteps "$remediationSteps" \
                                            --arg risk $risk" "\
                                            --arg severity $severity \
                                            --arg status "$status" \
                                            --arg cvss "$cvss" \
                                            --arg issueType "$issueType" \
                                            --arg lineNumber "$lineNumber" \
                                            --arg product "$product" \
                                            --argjson referenceIdentifiers "[{\"type\":\"CKV\", \"id\":\"$i\"}]" \
                                            '$ARGS.named'
                                        )

                                        a=$(jq -n \
                                            --argjson temp "[$element]" \
                                            --argjson issues "$arr" \
                                            '$ARGS.named'
                                        )
                                        
                                        # echo $a | jq '.'

                                        arr=$(echo $a | jq '.temp + .issues')

                                        echo $arr | jq . > issues.json

                                        i=$(( $i + 1 ))
                                done

                                issues=$(cat issues.json | jq '.')

                                jq -n \
                                    --argjson meta "{ \"key\":[\"issueName\"], \"author\":\"Terrascan\" }" \
                                    --argjson issues "$issues" \
                                    '$ARGS.named' \
                                    > scan.json

                                cat scan.json | jq .

                                cp scan.json /shared/customer_artifacts

                            timeout: 5m
                            failureStrategies:
                              - onFailure:
                                  errors:
                                    - Timeout
                                  action:
                                    type: Ignore
                    - parallel:
                        - step:
                            type: Security
                            name: STO TF Checkov
                            identifier: STO_TF_Checkov
                            spec:
                              privileged: true
                              settings:
                                policy_type: ingestionOnly
                                scan_type: repository
                                product_name: external
                                product_config_name: default
                                manual_upload_filename: checkov.json
                                customer_artifacts_path: /shared/customer_artifacts
                                repository_project: <+codebase.repoUrl>
                                repository_branch: main
                            failureStrategies:
                              - onFailure:
                                  errors:
                                    - AllErrors
                                  action:
                                    type: Ignore
                        - step:
                            type: Security
                            name: STO TF Terrascan
                            identifier: STO_TF_Terrascan
                            spec:
                              privileged: true
                              settings:
                                policy_type: ingestionOnly
                                scan_type: repository
                                product_name: external
                                product_config_name: default
                                manual_upload_filename: scan.json
                                customer_artifacts_path: /shared/customer_artifacts
                                repository_project: <+codebase.repoUrl>
                                repository_branch: main
                            failureStrategies:
                              - onFailure:
                                  errors:
                                    - AllErrors
                                  action:
                                    type: Ignore
              - step:
                  type: Run
                  name: Terraform Validate
                  identifier: TF_Validate
                  spec:
                    connectorRef: ${docker_ref}
                    image: hashicorp/terraform
                    shell: Sh
                    command: |-
                      cd harness-provision

                      terraform validate
                  failureStrategies:
                    - onFailure:
                        errors:
                          - AllErrors
                        action:
                          type: Ignore
          sharedPaths:
            - /var/run
            - /shared/customer_artifacts
    - stage:
        name: Terraform Provisioning
        identifier: Provisioning
        description: ""
        type: Custom
        spec:
          execution:
            steps:
              - stepGroup:
                  name: Terraform Plan
                  identifier: Terraform_Plan
                  steps:
                    - step:
                        type: TerraformPlan
                        name: TF Plan
                        identifier: TF_Plan
                        spec:
                          configuration:
                            command: Apply
                            workspace: <+stage.variables.tf_workspace>
                            configFiles:
                              store:
                                type: Github
                                spec:
                                  gitFetchType: Branch
                                  connectorRef: ${git_connector_ref}
                                  repoName: <+stage.variables.tf_repo_name>
                                  branch: <+stage.variables.tf_branch>
                                  folderPath: <+stage.variables.tf_folder>
                              moduleSource:
                                useConnectorCredentials: true
                            secretManagerRef: account.harnessSecretManager
                            backendConfig:
                              type: Inline
                              spec:
                                content: |-
                                  bucket = "<+stage.variables.tf_backend_bucket>"
                                  prefix = "<+stage.variables.tf_backend_prefix>"
                            environmentVariables:
                              - name: HARNESS_ACCOUNT_ID
                                value: <+stage.variables.harness_account_id>
                                type: String
                              - name: HARNESS_PLATFORM_API_KEY
                                value: <+stage.variables.harness_api_key>
                                type: String
                              - name: HARNESS_ENDPOINT
                                value: <+stage.variables.harness_endpoint>
                                type: String
                              - name: GOOGLE_BACKEND_CREDENTIALS
                                value: <+stage.variables.tf_gcp_keys>
                                type: String
                            varFiles:
                              - varFile:
                                  type: Remote
                                  identifier: tf_remote_seed_lab
                                  spec:
                                    store:
                                      type: Github
                                      spec:
                                        gitFetchType: Branch
                                        repoName: ""
                                        branch: <+stage.variables.tf_branch>
                                        paths:
                                          - tfvars/<+stage.variables.tf_workspace>/account.tfvars
                                          - tfvars/<+stage.variables.tf_workspace>/connectors.tfvars
                                          - tfvars/<+stage.variables.tf_workspace>/delegates.tfvars
                                          - tfvars/<+stage.variables.tf_workspace>/pipelines.tfvars
                                        connectorRef: ${git_connector_ref}
                              - varFile:
                                  identifier: vars
                                  spec:
                                    content: harness_platform_api_key = "<+stage.variables.harness_api_key>"
                                  type: Inline
                            exportTerraformPlanJson: true
                          provisionerIdentifier: <+stage.variables.tf_workspace>
                        timeout: 10m
                        failureStrategies: []
                    - step:
                        type: ShellScript
                        name: Export Plan
                        identifier: Export_Plan
                        spec:
                          shell: Bash
                          onDelegate: true
                          source:
                            type: Inline
                            spec:
                              script: tfplan=$(cat <+execution.steps.Terraform_Plan.steps.TF_Plan.plan.jsonFilePath>)
                          environmentVariables: []
                          outputVariables:
                            - name: tfplan
                              type: String
                              value: tfplan
                        timeout: 10m
                    - step:
                        type: Policy
                        name: Terraform Compliance Check
                        identifier: Terraform_Compliance_Check
                        spec:
                          policySets:
                            - account.Terraform_Compliance
                          type: Custom
                          policySpec:
                            payload: <+pipeline.stages.Provisioning.spec.execution.steps.Terraform_Plan.steps.Export_Plan.output.outputVariables.tfplan>
                        timeout: 10m
                  failureStrategies: []
                  delegateSelectors:
                    - ${delegate_ref}
              - step:
                  type: HarnessApproval
                  name: Approve
                  identifier: Approve
                  spec:
                    approvalMessage: Please review the following information and approve the pipeline progression
                    includePipelineExecutionHistory: true
                    approvers:
                      userGroups:
                        - account.SE_Admin
                      minimumCount: 1
                      disallowPipelineExecutor: false
                    approverInputs: []
                  timeout: 1d
                  when:
                    stageStatus: Success
                    condition: <+pipeline.stages.Provisioning.spec.execution.steps.Terraform_Plan.steps.Terraform_Compliance_Check.output.status> != "pass" && <+pipeline.stages.Provisioning.spec.execution.steps.Terraform_Plan.steps.Terraform_Cost_Governance.output.status> != "pass"
                  failureStrategies: []
              - stepGroup:
                  name: Terraform Execution
                  identifier: Terraform_Deployment
                  steps:
                    - parallel:
                        - step:
                            type: TerraformApply
                            name: TF Apply
                            identifier: TF_Apply
                            spec:
                              configuration:
                                type: InheritFromPlan
                              provisionerIdentifier: <+stage.variables.tf_workspace>
                            timeout: 1h
                            when:
                              stageStatus: Success
                              condition: <+stage.variables.tf_action> == "apply"
                            failureStrategies: []
                        - step:
                            type: TerraformDestroy
                            name: TF Destroy
                            identifier: TF_D
                            spec:
                              provisionerIdentifier: <+stage.variables.tf_workspace>
                              configuration:
                                type: Inline
                                spec:
                                  workspace: <+stage.variables.tf_workspace>
                                  configFiles:
                                    store:
                                      spec:
                                        connectorRef: ${git_connector_ref}
                                        gitFetchType: Branch
                                        branch: <+stage.variables.tf_branch>
                                        folderPath: <+stage.variables.tf_folder>
                                      type: Github
                                    moduleSource:
                                      useConnectorCredentials: true
                                  backendConfig:
                                    type: Inline
                                    spec:
                                      content: |-
                                        bucket = "<+stage.variables.tf_backend_bucket>"
                                        prefix = "<+stage.variables.tf_backend_prefix>"
                                  environmentVariables:
                                    - name: HARNESS_ACCOUNT_ID
                                      value: <+stage.variables.harness_account_id>
                                      type: String
                                    - name: HARNESS_PLATFORM_API_KEY
                                      value: <+stage.variables.harness_api_key>
                                      type: String
                                    - name: HARNESS_ENDPOINT
                                      value: <+stage.variables.harness_endpoint>
                                      type: String
                                    - name: GOOGLE_BACKEND_CREDENTIALS
                                      value: <+stage.variables.tf_gcp_keys>
                                      type: String
                                  varFiles:
                                    - varFile:
                                        type: Remote
                                        identifier: tf_remote_seed_lab
                                        spec:
                                          store:
                                            type: Github
                                            spec:
                                              gitFetchType: Branch
                                              repoName: ""
                                              branch: <+stage.variables.tf_branch>
                                              paths:
                                                - tfvars/<+stage.variables.tf_workspace>/account.tfvars
                                                - tfvars/<+stage.variables.tf_workspace>/connectors.tfvars
                                                - tfvars/<+stage.variables.tf_workspace>/delegates.tfvars
                                                - tfvars/<+stage.variables.tf_workspace>/pipelines.tfvars
                                              connectorRef: ${git_connector_ref}
                                    - varFile:
                                        identifier: vars
                                        spec:
                                          content: harness_platform_api_key = "<+stage.variables.harness_api_key>"
                                        type: Inline
                            timeout: 50m
                            when:
                              stageStatus: Success
                              condition: <+stage.variables.tf_action> == "destroy"
                            failureStrategies:
                              - onFailure:
                                  errors:
                                    - AllErrors
                                  action:
                                    type: Retry
                                    spec:
                                      retryCount: 1
                                      onRetryFailure:
                                        action:
                                          type: ManualIntervention
                                          spec:
                                            timeout: 30m
                                            onTimeout:
                                              action:
                                                type: Abort
                                      retryIntervals:
                                        - 1m
                    - step:
                        type: TerraformRollback
                        name: TF Rollback
                        identifier: TF_Rollback
                        spec:
                          provisionerIdentifier: <+stage.variables.tf_workspace>
                        timeout: 10m
                        when:
                          stageStatus: Failure
                        failureStrategies: []
                  failureStrategies: []
                  delegateSelectors:
                    - ${delegate_ref}
            rollbackSteps: []
        tags: {}
        failureStrategies: []
        variables:
          - name: tf_branch
            type: String
            description: ""
            value: <+input>
          - name: tf_folder
            type: String
            description: ""
            value: <+input>
          - name: tf_workspace
            type: String
            description: ""
            value: <+input>
          - name: tf_backend_bucket
            type: String
            description: ""
            value: <+input>
          - name: tf_backend_prefix
            type: String
            description: ""
            value: <+input>
          - name: tf_gcp_keys
            type: Secret
            description: ""
            value: account.Cristian_GOOGLE_BACKEND_CREDENTIALS
          - name: tf_action
            type: String
            description: ""
            value: <+input>
          - name: harness_api_key
            type: Secret
            description: ""
            value: account.cristian_harness_platform_api_key
          - name: harness_account_id
            type: String
            description: ""
            value: Io9SR1H7TtGBq9LVyJVB2w
          - name: harness_endpoint
            type: String
            description: ""
            value: https://app.harness.io/gateway
  properties:
    ci:
      codebase:
        connectorRef: ${git_connector_ref}
        repoName: ${git_repo_ref}
        build: <+input>
