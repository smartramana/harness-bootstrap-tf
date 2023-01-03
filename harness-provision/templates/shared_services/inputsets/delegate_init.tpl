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
          identifier: Provision_${suffix}
          type: Deployment
          variables:
            - name: k8s_connector_ref
              type: String
              value: "${k8s_connector_ref}"
            - name: delegate_ref
              type: String
              value: "${delegate_ref}"
            - name: enable_terraform
              type: String
              value: "${enable_terraform}"
            - name: TF_VERSION
              type: String
              value: "${TF_VERSION}"
            - name: enable_gcloud
              type: String
              value: "${enable_gcloud}"
            - name: os_linux_distro
              type: String
              value: "${os_linux_distro}"
