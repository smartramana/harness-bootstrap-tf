package pipeline_approval

# Deny pipelines that don't have an approval step
deny[sprintf("Build stage '%s' does not have a Security step", [input.pipeline.stages[i].stage.name])] {
    input.pipeline.stages[i].stage.type == "Build"  # Find all stages that are Builds ...
    not stages_with_security[i]                     # ... that are not in the set of stages with Security steps
}

# Find the set of stages that contain a Security step - try removing the Security step from your input to see the policy fail
stages_with_security[i] {
    input.pipeline.stages[i].stage.spec.execution.steps[_].step.type == "Security"
}
