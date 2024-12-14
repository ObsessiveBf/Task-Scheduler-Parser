
$taskDir = "C:\Windows\System32\Tasks"


$commandsFile = ".\commands.txt"
$argumentsFile = ".\arguments.txt"
$actionsFile = ".\actions.txt"
$detectionsFile = ".\detections.txt"


Remove-Item $commandsFile, $argumentsFile, $actionsFile, $detectionsFile -ErrorAction SilentlyContinue


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
        $taskXml = Get-Content -Path $taskFilePath -Raw
        $task = Register-ScheduledTask -Xml $taskXml -TaskName "TempTask" -WhatIf -PassThru

        foreach ($action in $task.Actions) {

            if ($action.Execute) {
                Add-Content -Path $commandsFile -Value ("{0} -> {1}" -f $taskFilePath, $action.Execute)
            }


            if ($action.Arguments) {
                Add-Content -Path $argumentsFile -Value ("{0} -> {1}" -f $taskFilePath, $action.Arguments)
            }


            Add-Content -Path $actionsFile -Value ("{0} -> ActionType: {1}" -f $taskFilePath, $action.ActionType)

            foreach ($keyword in $suspiciousKeywords) {
                if ($action.Execute -match $keyword -or $action.Arguments -match $keyword) {
                    Add-Content -Path $detectionsFile -Value ("{0} -> Detected keyword: {1}" -f $taskFilePath, $keyword)
                }
            }
        }
    } catch {
        Write-Host ("Error processing task: {0}" -f $taskFilePath) -ForegroundColor Red
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
Write-Host "Results saved in commands.txt, arguments.txt, actions.txt, and detections.txt in the current directory."


exit
