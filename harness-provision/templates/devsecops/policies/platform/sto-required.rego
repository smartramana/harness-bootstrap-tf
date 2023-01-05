package pipeline_approval

# Deny pipelines that don't have an approval step
deny[sprintf("Build stage '%s' does not have a Security step", [input.pipeline.stages[i].stage.name])] {
    input.pipeline.stages[i].stage.type == "CI"  # Find all stages that are Builds ...

    plainsteps := [ s | s = input.pipeline.stages[i].stage.spec.execution.steps[_].step.type ]
    stepgroups := [ s | s = input.pipeline.stages[i].stage.spec.execution.steps[_].stepGroup.steps[_].step.type ]
    parallelsteps := [ s | s = input.pipeline.stages[i].stage.spec.execution.steps[_].parallel[_].step.type ]
    parallelstepsstepgroups := [ s | s = input.pipeline.stages[i].stage.spec.execution.steps[_].stepGroup.steps[_].parallel[_].step.type ]

    v1 := array.concat(plainsteps, stepgroups)
    v2 := array.concat(v1, parallelsteps)
    v3 := array.concat(v2, parallelstepsstepgroups)

    required_step := required_steps[_]                

    not contains(v3, required_step)                   
}

required_steps = ["Security"]

contains(arr, elem) {
  arr[_] = elem
}