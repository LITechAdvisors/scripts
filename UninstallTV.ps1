## LI Tech Advisors ##
## TeamViewer Uninstall & Scrub ##


# Define the log file path
$logFilePath = "C:\temp\TeamViewer_Log.txt"

# Create C:\temp if it doesn't exist
if (-not (Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Function to log messages
function Write-Log {
    Param ([string]$message)
    Add-Content -Value $message -Path $logFilePath
}

# Log start of script
Write-Log "Starting TeamViewer removal process..."

# Check for TeamViewer uninstaller in both x86 and 64-bit Program Files
$uninstallPaths = @("C:\Program Files (x86)\TeamViewer\uninstall.exe", "C:\Program Files\TeamViewer\uninstall.exe")
$foundUninstaller = $false

foreach ($uninstallPath in $uninstallPaths) {
    if (Test-Path -Path $uninstallPath) {
        Write-Log "Uninstalling TeamViewer from $uninstallPath..."
        Start-Process -FilePath $uninstallPath -ArgumentList "/S" -Wait -NoNewWindow
        Write-Log "TeamViewer uninstalled from $uninstallPath."
        $foundUninstaller = $true
        break
    }
}

if (-not $foundUninstaller) {
    Write-Log "TeamViewer uninstaller not found."
}

# Uninstall TeamViewer programs
$teamViewerPrograms = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*TeamViewer*" }
foreach ($program in $teamViewerPrograms) {
    $programName = $program.Name
    Write-Log "Uninstalling $programName..."
    $program.Uninstall()
}

# Remove TeamViewer Services
$teamViewerServices = Get-Service | Where-Object { $_.DisplayName -like "*TeamViewer*" -or $_.Name -like "*TeamViewer*" }
foreach ($service in $teamViewerServices) {
    if ($service.Status -eq 'Running') {
        Stop-Service -Name $service.Name -Force
        Write-Log "Stopped service: $($service.Name)"
    }
    # Removing service using sc.exe command
    $removeServiceResult = sc.exe delete $service.Name
    Write-Log "Service removal result for $($service.Name): $removeServiceResult"
}

# Remove Firewall Rules
$teamViewerFirewallRules = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*TeamViewer*" }
foreach ($rule in $teamViewerFirewallRules) {
    Remove-NetFirewallRule -DisplayName $rule.DisplayName
    Write-Log "Removed firewall rule: $($rule.DisplayName)"
}

# Function to remove TeamViewer directories in a given path
function Remove-TeamViewerDirectories {
    Param ([string]$path)
    try {
        $teamViewerDirectories = Get-ChildItem -Path $path -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*TeamViewer*" }
        if ($teamViewerDirectories.Count -eq 0) {
            Write-Log "No TeamViewer directories found in $path."
            return
        }
        foreach ($dir in $teamViewerDirectories) {
            Remove-Item -Path $dir.FullName -Force -Recurse
            Write-Log "Removed directory: $($dir.FullName)"
        }
    }
    catch {
        Write-Log "Error encountered while removing TeamViewer directories in ${path}: $_"
    }
}

# Remove TeamViewer directories in C:\Program Files and C:\Program Files (x86)
Remove-TeamViewerDirectories "C:\Program Files"
Remove-TeamViewerDirectories "C:\Program Files (x86)"

# Function to remove leftover registry entries for TeamViewer
function Remove-TeamViewerRegistryEntries {
    Param ([string]$registryPath)
    try {
        $teamViewerRegEntries = Get-ItemProperty -Path "$registryPath\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*TeamViewer*" }
        foreach ($entry in $teamViewerRegEntries) {
            Remove-Item -Path "$registryPath\$($entry.PSChildName)" -Force
            Write-Log "Removed registry entry: $($entry.DisplayName) from $registryPath"
        }
    }
    catch {
        Write-Log "Error encountered while removing TeamViewer registry entries in ${registryPath}: $_"
    }
}

# Remove TeamViewer registry entries from both 64-bit and 32-bit paths
Remove-TeamViewerRegistryEntries "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
Remove-TeamViewerRegistryEntries "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

# Log completion of script
Write-Log "TeamViewer removal process completed."

# Display log file content
Get-Content -Path $logFilePath

