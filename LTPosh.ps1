#----Downloads Automate Uninstaller From your FQDN, Install or Download then Install Agent----
#!ps
#timeout=9000000
#maxlength=9000000
#ENTER YOUR FQDN INSIDE THE QUOTES ON THE LINE BELOW i.e.: 'https://litechadvisors.hostedrmm.com/'
$FQDN='https://litechadvisors.hostedrmm.com/'
#ENTER YOUR SERVER PASSWORD INSIDE THE QUOTES ON THE LINE BELOW (Located in the CONFIG table in the Automate database)
$SERVERPASS='jz4h/QcuGFDYlLc9XnXeqHR++un+ZTuO'
#--------------------------------------------------------
#--------------------------------------------------------
#--------------------------------------------------------
#--------------------------------------------------------
Write-Output "Your FQDN is set to: $($FQDN)"
Write-Output "Your System Password is set to: $($SERVERPASS)"
if (Test-Path c:\windows\ltsvc){
sc.exe config "LTService" start= disabled
sc.exe config "LTSvcMon" start= disabled
taskkill /im ltsvcmon.exe /f
taskkill /im lttray.exe /f
taskkill /im ltsvc.exe /f
$source = "$($FQDN)/labtech/service/LabUninstall.exe"
$Filename = [System.IO.Path]::GetFileName($source)
$dest = "C:\$Filename"
$wc = New-Object System.Net.WebClient
if (!(test-path $dest))
{if ((Test-Path $dest -OlderThan (Get-Date).AddHours(-24))){
Write-Output '-----------------------------------------'
Write-Output '------File is older than 24 hours old----'
Write-Output '------Deleting Old Uninstaller-----------'
Write-Output '-----------------------------------------'
remove-item C:\LabUninstall.exe}
Write-Output '-----------------------------------------'
write-Output '------Downloading Uninstaller Now--------'
Write-Output '-----------------------------------------'
Write-Output '-----------------------------------------'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$wc.DownloadFile($source, $dest)}
Else
{Write-Output '-----------------------------------------'
Write-Output '----Uninstaller Already Resides on C:\----'
Write-Output '---Using c:\Labuninstall.exe-------------'
Write-Output '---If you have issues with the uninstall-'
Write-Output '---Delete the uninstaller and run again--'}
Write-Output '-----------------------------------------'
Write-Output '---------------Uninstalling--------------'
C:\LabUninstall.exe /quiet /norestart
Write-Output '-----------------------------------------'
Write-Output '----Uninstall Started Waiting 90 Secs----'
Write-Output '-----------------------------------------'
Start-Sleep 90}
Else
{Write-Output '-----------------------------------------'
Write-Output '------LTSVC FOLDER DOES NOT EXIST--------'
Write-Output '-------SKIPPING UNINSTALL PROCESS---------'}
Write-Output '-----------------------------------------'
Write-Output '----------Download Agent Sequence---------'
Write-Output '-----------------------------------------'
$source2 = "$($FQDN)/labtech/service/LabTechRemoteAgent.msi"
$Filename = [System.IO.Path]::GetFileName($source2)
$dest2 = "C:\$Filename"
$wc = New-Object System.Net.WebClient
$file2 = 'C:\LabTechRemoteAgent.msi'
if (!(test-path $file2))
{if ((Test-Path $file2 -OlderThan (Get-Date).AddHours(-24))){
Write-Output '-----------------------------------------'
Write-Output '------File is older than 24 hours old----'
Write-Output '------Deleting Old Installer-----------'
Write-Output '-----------------------------------------'
remove-item C:\LabTechRemoteAgent.msi}
Write-Output '-----------------------------------------'
write-Output '--------Downloading Installer Now--------'
Write-Output '-----------------------------------------'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$wc.DownloadFile($source2, $dest2)}
Else
{Write-Output '----Installer Already Resides on C:\-----'
Write-Output '---Using c:\LabtechRemoteAgent.msi-------'
Write-Output '---If you have issues with the install---'
Write-Output '---Delete the installer and run again----'}
Write-Output '-----------------------------------------'
Write-Output '----------------Installing---------------'
Write-Output '-----------------------------------------'
$id = 1
msiexec.exe /i C:\LabTechRemoteAgent.msi /quiet LOCATION=$($id) SERVERADDRESS=$($FQDN) SERVERPASS=$($SERVERPASS)
Start-Sleep -s 60
Write-Output '-----------------------------------------'
Write-Output '------Verifying Services are Started-----'
Write-Output '-----------------------------------------'
sc.exe start ltsvcmon
sc.exe start ltservice
Write-Output '-----------------------------------------'
Write-Output '-------Contents of LTSVC Folder:---------'
Write-Output '-----------------------------------------'
ls c:\Windows\LTSVC
Write-Output '-----------------------------------------'
Write-Output '------Contents of LTErrors.txt File:-----'
Write-Output '-----------------------------------------'
type c:\windows\ltsvc\lterrors.txt