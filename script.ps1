# Set the directory to scan
$taskDir = "C:\Windows\System32\Tasks"

# Define output files
$commandsFile = ".\commands.txt"
$argumentsFile = ".\arguments.txt"
$actionsFile = ".\actions.txt"

# Clear previous output
Remove-Item $commandsFile, $argumentsFile, $actionsFile -ErrorAction SilentlyContinue

# Loading sequence
Write-Host "Scanning tasks in $taskDir and subfolders..." -ForegroundColor Yellow
$counter = 0

# Function to process tasks in a folder
function Process-Tasks($folder) {
    $tasks = Get-ChildItem -Path $folder -Recurse -File

    foreach ($taskFile in $tasks) {
        try {
            $task = Register-ScheduledTask -Xml (Get-Content $taskFile.FullName | Out-String) -TaskName "TempTask" -WhatIf -PassThru
            foreach ($action in $task.Actions) {
                $counter++
                # Log the executable (commands)
                if ($action.Execute) {
                    Add-Content -Path $commandsFile -Value "$($taskFile.Name) -> $($action.Execute)"
                }

                # Log the arguments
                if ($action.Arguments) {
                    Add-Content -Path $argumentsFile -Value "$($taskFile.Name) -> $($action.Arguments)"
                }

                # Log the action type
                Add-Content -Path $actionsFile -Value "$($taskFile.Name) -> ActionType: $($action.ActionType)"
            }
        } catch {
            Write-Host "Error processing task: $($taskFile.FullName)" -ForegroundColor Red
        }
    }
}

# Recursively process all tasks in the main directory and subfolders
Process-Tasks $taskDir

# Completion message
Write-Host "Scan complete! Processed $counter tasks." -ForegroundColor Green
Write-Host "Results saved in commands.txt, arguments.txt, and actions.txt in the current directory."

# Exit gracefully
exit
