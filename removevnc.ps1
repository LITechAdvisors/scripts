# Define the log file path
$logFilePath = "C:\temp\VNC_Log.txt"

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
Write-Log "Starting VNC removal process..."

# Specific uninstall for UltraVNC
$uninstallPath = "C:\Program Files\UltraVNC\unins000.exe"
if (Test-Path -Path $uninstallPath) {
    Write-Log "Uninstalling UltraVNC..."
    Start-Process -FilePath $uninstallPath -ArgumentList "/SILENT /NORESTART" -Wait -NoNewWindow
    Write-Log "UltraVNC uninstalled."
} else {
    Write-Log "UltraVNC uninstaller not found."
}

# Specific uninstall for RealVNC
$uninstallPath = "C:\Program Files\RealVNC\VNC4\unins000.exe"
if (Test-Path -Path $uninstallPath) {
    Write-Log "Uninstalling RealVNC..."
    Start-Process -FilePath $uninstallPath -ArgumentList "/SILENT /NORESTART" -Wait -NoNewWindow
    Write-Log "RealVNC uninstalled."
} else {
    Write-Log "RealVNC uninstaller not found."
}

# Uninstall VNC programs
$vncPrograms = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*VNC*" }
foreach ($program in $vncPrograms) {
    $programName = $program.Name
    Write-Log "Uninstalling $programName..."
    $program.Uninstall()
}

# Remove VNC Services
$vncServices = Get-Service | Where-Object { $_.DisplayName -like "*VNC*" -or $_.Name -like "*VNC*" }
foreach ($service in $vncServices) {
    if ($service.Status -eq 'Running') {
        Stop-Service -Name $service.Name -Force
        Write-Log "Stopped service: $($service.Name)"
    }
    # Removing service using sc.exe command
    $removeServiceResult = sc.exe delete $service.Name
    Write-Log "Service removal result for $($service.Name): $removeServiceResult"
}

# Remove Firewall Rules
$vncFirewallRules = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*VNC*" }
foreach ($rule in $vncFirewallRules) {
    Remove-NetFirewallRule -DisplayName $rule.DisplayName
    Write-Log "Removed firewall rule: $($rule.DisplayName)"
}

# Function to remove VNC directories in a given path
function Remove-VncDirectories {
    Param ([string]$path)
    try {
        $vncDirectories = Get-ChildItem -Path $path -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*VNC*" }
        if ($vncDirectories.Count -eq 0) {
            Write-Log "No VNC directories found in $path."
            return
        }
        foreach ($dir in $vncDirectories) {
            Remove-Item -Path $dir.FullName -Force -Recurse
            Write-Log "Removed directory: $($dir.FullName)"
        }
    }
    catch {
        Write-Log "Error encountered while removing VNC directories in ${path}: $_"
    }
}

# Function to remove VNC directories in a given path
function Remove-VncDirectories {
    Param ([string]$path)
    try {
        $vncDirectories = Get-ChildItem -Path $path -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*VNC*" }
        if ($vncDirectories.Count -eq 0) {
            Write-Log "No VNC directories found in $path."
            return
        }
        foreach ($dir in $vncDirectories) {
            Remove-Item -Path $dir.FullName -Force -Recurse
            Write-Log "Removed directory: $($dir.FullName)"
        }
    }
    catch {
        Write-Log "Error encountered while removing VNC directories in ${path}: $_"
    }
}

# Remove VNC directories in C:\Program Files and C:\Program Files (x86)
Remove-VncDirectories "C:\Program Files"
Remove-VncDirectories "C:\Program Files (x86)"

# Rest of your script...


# Log completion of script
Write-Log "VNC removal process completed."

# Display log file content
Get-Content -Path $logFilePath
