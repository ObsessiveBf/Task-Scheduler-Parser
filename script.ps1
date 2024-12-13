# Set the directory to scan
$taskDir = "C:\Windows\System32\Tasks"

# Define output files
$commandsFile = ".\commands.txt"
$argumentsFile = ".\arguments.txt"
$actionsFile = ".\actions.txt"

# Clear previous output
Remove-Item $commandsFile, $argumentsFile, $actionsFile -ErrorAction SilentlyContinue

# Loading sequence message
Write-Host "Scanning tasks in $taskDir and subfolders..." -ForegroundColor Yellow

# Function to process a single task file
function Process-TaskFile {
    param (
        [string]$taskFilePath
    )
    try {
        $taskXml = Get-Content -Path $taskFilePath -Raw
        $task = Register-ScheduledTask -Xml $taskXml -TaskName "TempTask" -WhatIf -PassThru

        foreach ($action in $task.Actions) {
            # Log the executable (commands)
            if ($action.Execute) {
                Add-Content -Path $commandsFile -Value ("{0} -> {1}" -f $taskFilePath, $action.Execute)
            }

            # Log the arguments
            if ($action.Arguments) {
                Add-Content -Path $argumentsFile -Value ("{0} -> {1}" -f $taskFilePath, $action.Arguments)
            }

            # Log the action type
            Add-Content -Path $actionsFile -Value ("{0} -> ActionType: {1}" -f $taskFilePath, $action.ActionType)
        }
    } catch {
        Write-Host "Error processing task: $taskFilePath" -ForegroundColor Red
    }
}

# Initialize counter and scan recursively
$allTasks = Get-ChildItem -Path $taskDir -Recurse -File
$totalTasks = $allTasks.Count
$counter = 0

foreach ($taskFile in $allTasks) {
    $counter++
    # Display progress
    Write-Host ("Processing task {0} / {1}: {2}" -f $counter, $totalTasks, $taskFile.Name) -ForegroundColor Cyan
    Process-TaskFile -taskFilePath $taskFile.FullName
}

# Completion message
Write-Host "`nScan complete! Processed $counter tasks." -ForegroundColor Green
Write-Host "Results saved in commands.txt, arguments.txt, and actions.txt in the current directory."

# Allow user to continue typing in the command prompt
exit
