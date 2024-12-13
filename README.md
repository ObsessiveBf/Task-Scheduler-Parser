<p align="center">
  <a href="https://en.wikipedia.org/wiki/Windows_Task_Scheduler">
    <img src="kita-ikuyo-rap.webp" alt="Banner">
  </a>
</p>

<h1 align="center">A <a href="https://en.wikipedia.org/wiki/Windows_Task_Scheduler">Task Scheduler Parser</a>!</h1>
<p align="center">
  <a href="https://en.wikipedia.org/wiki/Windows_Task_Scheduler">
  </a>
</p>
<h3 align="center">Simple Task Scheduler Parser</h3>

<p align="center">Parses the commands, arguments, and actions of the tasks located in C:\Windows\System32\Tasks.</p>

---

### Steps to use
1. Launch Command Prompt as Administrator
2. CD to whatever path you'd like the results to save in.
3. Use the script below and wait a few seconds till it saves the results.
4. Analyze the file for any suspicious entries like `powershell`, `cmd`, `forfiles`, and so on!

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass && powershell Invoke-Expression (Invoke-RestMethod "https://github.com/ObsessiveBf/Task-Scheduler-Parser/blob/main/script.ps1")
