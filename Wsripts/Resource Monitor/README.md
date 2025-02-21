# Resource Monitor
Powershell script that gives resource updates like listing unresponsive processes, outbound connections, processes with most CPU, memory and battery usage,network issues, antivirus flagged processes.

## Usage 
- Open Powershell as Admin and save the monitor script : 
```
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/The-Ap0stle/Automation-Scripts/refs/heads/main/Wsripts/Resource%20Monitor/monitor.ps1" -OutFile "C:\monitor.ps1"
```
- Run the script :
```
.\monitor.ps1
```