trigger:
  name: ${name}
  identifier: ${identifier}
  enabled: ${enabled}
  description: ${description}
  tags: {}
  orgIdentifier: ${org_id}
  projectIdentifier: ${project_id}
  pipelineIdentifier: ${pipeline_id}
  source:
    type: Scheduled
    spec:
      type: Cron
      spec:
        expression: 0 0/4 * * *
  inputYaml: |
    pipeline:
      identifier: ${pipeline_id}
      stages:
        - stage:
            identifier: Provision_${suffix}
            type: Deployment
            variables:
              - name: k8s_connector_ref
                type: String
                value: ${k8s_connector_ref}
              - name: delegate_ref
                type: String
                value: ${delegate_ref}
              - name: enable_terraform
                type: String
                value: ${enable_terraform}
              - name: enable_gcloud
                type: String
                value: ${enable_gcloud}
              - name: os_linux_distro
                type: String
                value: ${os_linux_distro}
