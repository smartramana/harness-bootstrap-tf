pipeline:
  name: ${name}
  identifier: ${name}_${suffix}
  projectIdentifier: ${project_id}
  orgIdentifier: ${org_id}
  tags: {}
  stages:
    - stage:
        name: Provision
        identifier: Provision_${suffix}
        description: ""
        type: Deployment
        spec:
          serviceConfig:
            serviceRef: ${service_ref}
            serviceDefinition:
              spec:
                variables: []
              type: Kubernetes
          infrastructure:
            environmentRef: ${environment_ref}
            infrastructureDefinition:
              type: KubernetesDirect
              spec:
                connectorRef: <+stage.variables.connector_ref>
                namespace: harness-delegate-ng
                releaseName: release-<+INFRA_KEY>
            allowSimultaneousDeployments: false
          execution:
            steps:
              - step:
                  type: ShellScript
                  name: Update Linux Dependencies
                  identifier: Update_Linux_Dependencies
                  spec:
                    shell: Bash
                    onDelegate: true
                    source:
                      type: Inline
                      spec:
                        script: |-
                          echo "update linux dependencies"

                          export DEBIAN_FRONTEND=noninteractive

                          apt-get update
                          apt-get install -y \
                              gnupg \
                              software-properties-common \
                              curl \
                              git
                    environmentVariables: []
                    outputVariables: []
                  timeout: 10m
              - step:
                  type: ShellScript
                  name: Install Terraform Binary
                  identifier: Install_Terraform_Binary
                  spec:
                    shell: Bash
                    onDelegate: true
                    source:
                      type: Inline
                      spec:
                        script: |-
                          echo "install terraform"

                          curl -sL https://releases.hashicorp.com/terraform/<+stage.variables.TF_VERSION>/terraform_<+stage.variables.TF_VERSION>_linux_amd64.zip -o terraform.zip

                          # Install terraform
                          unzip terraform.zip
                          chmod +x terraform
                          mv terraform /usr/bin/terraform
                    environmentVariables: []
                    outputVariables: []
                  timeout: 10m
                  when:
                    stageStatus: Success
                    condition: <+stage.variables.enable_terraform> == "true"
                  failureStrategies: []
            rollbackSteps: []
        tags: {}
        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: Abort
        variables:
          - name: TF_VERSION
            type: String
            description: ""
            value: 1.2.8
          - name: connector_ref
            type: String
            description: ""
            value: <+input>
          - name: enable_terraform
            type: String
            description: ""
            value: <+input>