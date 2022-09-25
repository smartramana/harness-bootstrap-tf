pipeline:
  name: Harness TF BCP Account Setup
  identifier: Harness_TF_BCP_Account_Setup
  template:
    templateRef: ${template_ref}
    versionLabel: ${version}
    templateInputs:
      stages:
        - stage:
            identifier: Provisioning
            type: Custom
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
  tags: {}
  projectIdentifier: ${project_identifier}
  orgIdentifier: ${org_identifier}
