template:
  name: Terraform STO
  identifier: "${identifier}"
  versionLabel: "${version}"
  type: Stage
  tags: {}
  spec:
    type: CI
    spec:
      cloneCodebase: true
      infrastructure:
        type: KubernetesDirect
        spec:
          connectorRef: <+stage.variables.k8s_connector_ref>
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
                          connectorRef: <+stage.variables.docker_connector_ref>
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
                          connectorRef: <+stage.variables.docker_connector_ref>
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
                          connectorRef: <+stage.variables.docker_connector_ref>
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
                          connectorRef: <+stage.variables.docker_connector_ref>
                          image: ubuntu
                          shell: Sh
                          command: |
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
                          connectorRef: <+stage.variables.docker_connector_ref>
                          image: alpine
                          shell: Sh
                          command: |
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
                connectorRef: <+stage.variables.docker_connector_ref>
                image: hashicorp/terraform
                shell: Sh
                command: |-
                  cd <+stage.variables.tf_folder>

                  terraform init \
                      -backend-config="bucket=<+stage.variables.tf_backend_bucket>" \
                      -backend-config="prefix=<+stage.variables.tf_backend_prefix>"

                  terraform workspace select <+stage.variables.tf_workspace> || terraform workspace new <+stage.variables.tf_workspace>

                  TF_VAR_harness_platform_api_key=<+secrets.getValue("account.cristian_harness_platform_api_key")> terraform plan \
                      -var-file=../tfvars/<+stage.variables.tf_workspace>/account.tfvars \
                      -var-file=../tfvars/<+stage.variables.tf_workspace>/connectors.tfvars \
                      -var-file=../tfvars/<+stage.variables.tf_workspace>/delegates.tfvars \
                      -var-file=../tfvars/<+stage.variables.tf_workspace>/pipelines.tfvars \
                      -var-file=../tfvars/<+stage.variables.tf_workspace>/templates.tfvars

                  terraform validate
                envVariables:
                  GOOGLE_BACKEND_CREDENTIALS: <+secrets.getValue("account.Cristian_GOOGLE_BACKEND_CREDENTIALS")>
                  HARNESS_PLATFORM_API_KEY: <+secrets.getValue("account.cristian_harness_platform_api_key")>
                  GITHUB_TOKEN: <+secrets.getValue("account.crizstian_github_token")>
                  HARNESS_ENDPOINT: "https://app.harness.io/gateway"
                  HARNESS_ACCOUNT_ID: Io9SR1H7TtGBq9LVyJVB2w
      sharedPaths:
        - /var/run
        - /shared/customer_artifacts
    when:
      pipelineStatus: Success
    variables:
      - name: k8s_connector_ref
        type: String
        description: ""
        value: <+input>
      - name: docker_connector_ref
        type: String
        description: ""
        value: <+input>
      - name: tf_folder
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
      - name: tf_workspace
        type: String
        description: ""
        value: <+input>