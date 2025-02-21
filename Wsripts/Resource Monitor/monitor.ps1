Write-Host "[+] Gathering data... Please wait." -ForegroundColor Cyan
$OutputFile = "C:\Monitor_Report.txt"

# Function to get unresponsive processes
function Get-UnresponsiveProcesses {
    Write-Host "`n[+] Checking for unresponsive processes..." -ForegroundColor Yellow
    Get-Process | Where-Object { $_.Responding -eq $false } | Select-Object Name, Id, MainWindowTitle | Format-Table -AutoSize
}

# Function to get all outbound network connections
function Get-NetworkConnections {
    Write-Host "`n[+] Checking outbound network connections..." -ForegroundColor Yellow
    Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess | Sort-Object LocalPort | Format-Table -AutoSize
}

# Function to get high resource usage processes
function Get-HighUsageProcesses {
    Write-Host "`n[+] Checking for high resource usage processes..." -ForegroundColor Yellow
    
    Write-Host "`n    - Top CPU Consuming Processes:"
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, Id, CPU | Format-Table -AutoSize

    Write-Host "`n    - Top Memory Consuming Processes:"
    Get-Process | Sort-Object WS -Descending | Select-Object -First 5 Name, Id, WS | Format-Table -AutoSize
    
    Write-Host "`n    - Top Battery Usage Processes (if applicable):"
    Get-CimInstance Win32_Battery | Select-Object EstimatedChargeRemaining, BatteryStatus | Format-Table -AutoSize
}

# Function to detect network issues
function Get-NetworkIssues {
    Write-Host "`n[+] Checking network issues..." -ForegroundColor Yellow
    Test-NetConnection -ComputerName google.com | Format-List
}

# Function to check antivirus flags (Windows Defender)
function Get-AntivirusThreats {
    Write-Host "`n[+] Checking Windows Defender for flagged threats..." -ForegroundColor Yellow
    try {
        Get-MpThreatDetection | Select-Object ThreatID, ThreatName, ActionTaken, Resources | Format-Table -AutoSize
    }
    catch {
        Write-Host "Windows Defender might not be active or accessible." -ForegroundColor Red
    }
}

# Function to collect system info
function Get-SystemInfo {
    Write-Host "`n[+] Gathering system information..." -ForegroundColor Yellow
    systeminfo | Out-File -Append $OutputFile
}

# Running all functions
Get-UnresponsiveProcesses
Get-NetworkConnections
Get-HighUsageProcesses
Get-NetworkIssues
Get-AntivirusThreats
Get-SystemInfo

Write-Host "`n[+] Troubleshooting Complete! Report saved to $OutputFile" -ForegroundColor Green
