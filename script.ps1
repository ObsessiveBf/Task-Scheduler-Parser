# Set the directory to scan
$taskDir = "C:\Windows\System32\Tasks"

# Define output files
$commandsFile = ".\commands.txt"
$argumentsFile = ".\arguments.txt"
$actionsFile = ".\actions.txt"
$detectionsFile = ".\detections.txt"
$errorsFile = ".\errors.txt"

# Clear previous output
Remove-Item $commandsFile, $argumentsFile, $actionsFile, $detectionsFile, $errorsFile -ErrorAction SilentlyContinue

# Suspicious keywords to detect
$suspiciousKeywords = @(
    "CMD",
    "Type",
    "Echo",
    "Powershell",
    "Powershell_ISE",
    "PowershellISE",
    "TaskScheduler",
    "Task_Scheduler",
    "MMC"
)

# Loading sequence message
Write-Host "Scanning tasks in $taskDir and subfolders..." -ForegroundColor Yellow

# Function to process a single task file
function Process-TaskFile {
    param (
        [string]$taskFilePath
    )
    try {
        # Read and parse the task file as XML
        $taskXml = Get-Content -Path $taskFilePath -Raw -ErrorAction Stop
        $task = [xml]$taskXml

        # Ensure the task has actions
        if (-not $task.Task.Actions) {
            Add-Content -Path $errorsFile -Value ("{0} -> No actions found" -f $taskFilePath)
            return
        }

        # Process each action
        foreach ($action in $task.Task.Actions.Exec) {
            $command = $action.Command
            $arguments = $action.Arguments

            # Log the executable (commands)
            if ($command) {
                Add-Content -Path $commandsFile -Value ("{0} -> {1}" -f $taskFilePath, $command)
            }

            # Log the arguments
            if ($arguments) {
                Add-Content -Path $argumentsFile -Value ("{0} -> {1}" -f $taskFilePath, $arguments)
            }

            # Check for suspicious keywords (exact match)
            foreach ($keyword in $suspiciousKeywords) {
                $regex = "\b$keyword\b" # Match whole word only
                if ($command -match $regex -or $arguments -match $regex) {
                    Add-Content -Path $detectionsFile -Value ("{0} -> Detected keyword: {1}" -f $taskFilePath, $keyword)
                }
            }
        }

        # Log successfully processed tasks
        Write-Host ("Processed successfully: {0}" -f $taskFilePath) -ForegroundColor Green
    } catch {
        # Log errors to errors.txt
        Add-Content -Path $errorsFile -Value ("Error processing {0}: {1}" -f $taskFilePath, $_.Exception.Message)
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
Write-Host "Results saved in commands.txt, arguments.txt, actions.txt, detections.txt, and errors.txt in the current directory."

# Allow user to continue typing in the command prompt
exit
