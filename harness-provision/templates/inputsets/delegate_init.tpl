inputSet:
  identifier: ${identifier}
  name: ${name}
  tags: {}
  projectIdentifier: ${project_id}
  orgIdentifier: ${org_id}
  pipeline:
    identifier: ${pipeline_id}
    stages:
      - stage:
          identifier: delegate_init_inputset
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
