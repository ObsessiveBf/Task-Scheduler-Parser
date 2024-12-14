$taskDir = "C:\Windows\System32\Tasks"

$commandsFile = ".\commands.txt"
$argumentsFile = ".\arguments.txt"
$actionsFile = ".\actions.txt"
$detectionsFile = ".\detections.txt"
$errorsFile = ".\errors.txt"

Remove-Item $commandsFile, $argumentsFile, $actionsFile, $detectionsFile, $errorsFile -ErrorAction SilentlyContinue

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


Write-Host "Scanning tasks in $taskDir and subfolders..." -ForegroundColor Yellow


function Process-TaskFile {
    param (
        [string]$taskFilePath
    )
    try {

        $taskXml = Get-Content -Path $taskFilePath -Raw -ErrorAction Stop
        $task = [xml]$taskXml


        if (-not $task.Task.Actions) {
            Add-Content -Path $errorsFile -Value ("{0} -> No actions found" -f $taskFilePath)
            return
        }


        foreach ($action in $task.Task.Actions.Exec) {
            $command = $action.Command
            $arguments = $action.Arguments


            if ($command) {
                Add-Content -Path $commandsFile -Value ("{0} -> {1}" -f $taskFilePath, $command)
            }


            if ($arguments) {
                Add-Content -Path $argumentsFile -Value ("{0} -> {1}" -f $taskFilePath, $arguments)
            }


            foreach ($keyword in $suspiciousKeywords) {
                $regex = "\b$keyword\b" 
                if ($command -match $regex -or $arguments -match $regex) {
                    Add-Content -Path $detectionsFile -Value ("{0} -> Detected keyword: {1}" -f $taskFilePath, $keyword)
                }
            }
        }


        Write-Host ("Processed successfully: {0}" -f $taskFilePath) -ForegroundColor Green
    } catch {

        Add-Content -Path $errorsFile -Value ("Error processing {0}: {1}" -f $taskFilePath, $_.Exception.Message)
    }
}


$allTasks = Get-ChildItem -Path $taskDir -Recurse -File
$totalTasks = $allTasks.Count
$counter = 0

foreach ($taskFile in $allTasks) {
    $counter++

    Write-Host ("Processing task {0} / {1}: {2}" -f $counter, $totalTasks, $taskFile.Name) -ForegroundColor Cyan
    Process-TaskFile -taskFilePath $taskFile.FullName
}


Write-Host "`nScan complete! Processed $counter tasks." -ForegroundColor Green
Write-Host "Results saved in commands.txt, arguments.txt, actions.txt, detections.txt, and errors.txt in the current directory."


exit
