package pipeline_approval

# Deny pipelines that don't have an approval step
deny[sprintf("deployment stage '%s' does not have a HarnessApproval step", [input.pipeline.stages[i].stage.name])] {
    input.pipeline.stages[i].stage.type == "Deployment"  # Find all stages that are Deployments ...
    not stages_with_approval[i]                          # ... that are not in the set of stages with HarnessApproval steps
}

# Find the set of stages that contain a HarnessApproval step - try removing the HarnessApproval step from your input to see the policy fail
stages_with_approval[i] {
    input.pipeline.stages[i].stage.spec.execution.steps[_].step.type == "HarnessApproval"
}
