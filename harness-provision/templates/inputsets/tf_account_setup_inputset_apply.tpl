inputSet:
  identifier: "tf_base_apply_${suffix}"
  name: "tf_base_apply"
  tags: {}
  projectIdentifier: ${project_identifier}
  orgIdentifier: ${org_identifier}
  pipeline:
    identifier: "TF_Account_Setup"
    stages:
    - stage:
        identifier: "Provisioning"
        type: "Custom"
        variables:
        - name: "tf_provision_identifier"
          type: "String"
          value: "${tf_provision_identifier}"
        - name: "tf_branch"
          type: "String"
          value: "<+codebase.sourceBranch>"
        - name: "tf_folder"
          type: "String"
          value: "${tf_folder}"
        - name: "tf_workspace"
          type: "String"
          value: "${tf_workspace}"
        - name: "tf_remote_vars"
          type: "String"
          value: "${tf_remote_vars}"
        - name: "tf_backend_bucket"
          type: "String"
          value: "${tf_backend_bucket}"
        - name: "tf_backend_prefix"
          type: "String"
          value: "${tf_backend_prefix}"
        - name: "tf_action"
          type: "String"
          value: "apply"