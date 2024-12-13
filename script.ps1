# Define file names for results
$commandsFile = ".\commands.txt"
$argumentsFile = ".\arguments.txt"
$actionsFile = ".\actions.txt"

# Clear previous output
Remove-Item $commandsFile, $argumentsFile, $actionsFile -ErrorAction SilentlyContinue

# Get all scheduled tasks
$tasks = Get-ScheduledTask

foreach ($task in $tasks) {
    $taskName = $task.TaskName

    # Get task actions
    $taskActions = (Get-ScheduledTask -TaskName $taskName).Actions

    foreach ($action in $taskActions) {
        if ($action -is [Microsoft.Management.Infrastructure.CimInstance]) {
            $executable = $action.Execute
            $arguments = $action.Arguments
            $actionType = $action.ActionType

            # Log the executable (commands)
            if ($executable) {
                Add-Content -Path $commandsFile -Value "$taskName -> $executable"
            }

            # Log the arguments
            if ($arguments) {
                Add-Content -Path $argumentsFile -Value "$taskName -> $arguments"
            }

            # Log the action type
            Add-Content -Path $actionsFile -Value "$taskName -> ActionType: $actionType"
        }
    }
}

Write-Output "Parsing completed. Results saved as 'commands.txt', 'arguments.txt', and 'actions.txt' in the current directory."
