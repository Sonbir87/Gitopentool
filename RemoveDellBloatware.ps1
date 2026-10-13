<#
.SYNOPSIS
    Comprehensive Dell Bloatware removal (no UWP apps).

.DESCRIPTION
    1) Silently uninstalls all known Dell MSI packages by GUID.
    2) Silently uninstalls all known Dell EXE-based uninstallers.
    3) Dynamically scans the registry for any remaining “Dell” apps and uninstalls them.
    4) Deletes Dell scheduled tasks and services.

    Logs every action (and errors) to C:\Temp\DellBloatwareRemoval.log.

    a lot of GUIDS and Exe from https://gist.github.com/tsfahmed2/5385b56e9a2d387ca61b355b90541084
#>

# Prevent terminating errors from stopping the script
$ErrorActionPreference = 'Continue'

#region Configuration
# Path to log file
$LogFile = 'C:\Temp\DellBloatwareRemoval.log'

# MSI-based Dell applications (GUIDs, without braces)
$DellGuids = @(
     '5669AB71-1302-4412-8DA1-CB69CD7B7324', # Dell Command | Update for Windows 10
     '4CCADC13-F3AE-454F-B724-33F6D4E52022', # Dell Command | Update for Windows 10
     'EC542D5D-B608-4145-A8F7-749C02BE6D94', # Dell Command | Update for Windows 10
     '41D2D254-D869-4CD8-B440-5DF49083C4BA', # Dell Command | Update for Windows 10
     'D8AE5F9D-647C-49B4-A666-1C20B44EC0E1', # Dell Update
     '70E9F8CC-A23E-4C25-B292-C86C1821587C', # Dell Update for Windows 10
     'CC5730C7-C867-43BD-94DA-00BB3836906F', # Dell Digital Delivery Services
     '66E2407E-9001-483E-B2AA-7AEF97567143', # Dell Digital Delivery Services
     '81C48559-E2EB-4F18-9854-51331B9DB552', # Dell Digital Delivery Services
     '3722784A-D530-4C82-BB78-4DF3E1A4CAD9', # Dell Digital Delivery Services
     '693A23FB-F28B-4F7A-A720-4C1263F97F43', # Dell Digital Delivery Services
     '560DFD4A-23E2-45DD-A223-A4B3FA356913', # Dell Digital Delivery Services
     '6B8F1793-AB75-4A01-B72D-CC2B54B19759', # Dell Digital Delivery Services
     'AADBB088-81DE-4EC8-B176-D98669BE09D4', # SupportAssist Update Plugin
     'EDE60887-F1EA-4304-A3E9-806D29EEE3FB', # SupportAssist Update Plugin
     'C559D0AB-2D9E-4B59-B2B8-0C2061B3F9BC', # SupportAssist Update Plugin
     '8B6D8EEE-9EE4-4FA3-9EC6-87BE5D130CB6', # SupportAssist Update Plugin
     '8FA6BC9C-CF6A-45E7-92BD-1585DFAFB32C', # Dell SupportAssist Remediation
     '2B2C47D2-F037-4C03-B599-07D7AFE8DD54', # Dell SupportAssist Remediation
     '1906C253-4035-4CA5-A501-075E691CCEC9', # Dell SupportAssist Remediation
     'C4EF62FF-E6B9-4CE8-A514-1DDA49CB0C47', # Dell SupportAssist Remediation
     '795931D8-2EBF-4969-A678-4219B161F676', # Dell SupportAssist Remediation
     '10B1BCF9-4996-4270-A12D-1B1BFEEF979C', # Dell SupportAssist Remediation
     '61A1B864-0DAF-45A4-8184-5A0D347803B1', # Dell SupportAssist Remediation
     '6B991B44-B938-4902-BDF3-186CBDC62AD3', # Dell SupportAssist Remediation
     'E21419F5-2AA6-439C-B2C1-840083A05BC5', # Dell SupportAssist Remediation
     '28C1FA1E-C3B3-4257-A3F2-059EEA260C64', # Dell SupportAssist Remediation
     '398E49A0-84CA-43B5-A926-42EF68619E91', # Dell SupportAssist Remediation
     '3A0ECCB6-1034-440E-8672-C4E14CCB7689', # Dell SupportAssist
     '5106801D-CA18-4173-85B9-D74C33358F7F', # Dell SupportAssist
     '9EF0AEB0-9AD2-40E6-8667-D7520C508941', # Dell SupportAssist
     '71A59A4C-9348-4CA2-B98C-E422E14C9D31', # Dell SupportAssist
     'E0659C89-D276-4B77-A5EC-A8F2F042E78F', # Dell SupportAssist
     '900D0BCD-0B86-4DAA-B639-89BE70449569', # Dell SupportAssist OS Recovery Plugin for Dell Update
     '6DD27BB4-C350-414B-BC25-D33246605FB2', # Dell SupportAssist OS Recovery Plugin for Dell Update
     'A713BCAE-ED3C-43BA-834A-8D1E8773FF2C', # Dell SupportAssist OS Recovery Plugin for Dell Update
     '39BF0E71-7A16-4A80-BBCE-FBDD2D1CC2D5', # Dell SupportAssist OS Recovery Plugin for Dell Update
     '18469ED8-8C36-4CF7-BD43-0FC9B1931AF8', # Dell Power Manager Service
     'BDB50421-E961-42F3-B803-6DAC6F173834', # Dell Foundation Services
     '6250A087-31F9-47E2-A0EF-56ABF31B610E', # Dell Core Services
     '2F3E37A4-8F48-465A-813B-1F2964DBEB6A', # Dell Watchdog Timer	
     'E2CAA395-66B3-4772-85E3-6134DBAB244E', # Dell Protected Workspace
     'E9CD23E0-FC9B-4AE6-83A1-067FC62A39E7', # Dell Digital Delivery Services
     'D2E875B4-E71A-4AD2-9E0C-3E097A3D54FC', # Dell Command | Update for Windows Universal 4.8
     '9D377E41-9055-48E9-8109-59D777A78AAA', # Dell Core Services
     '286A9ADE-A581-43E8-AA85-6F5D58C7DC88', # Dell Optimizer Core
     'cf89b953-b6ce-48b6-9af6-03eb3bff3e2c', # Dell SupportAssist Remediation
     '21155715-548F-48D0-B5D1-3D030E8C22B3', # Dell Trusted Device Agent
     '691ecb5d-557a-41d2-b485-92352068d819' # Dell SupportAssist OS Recovery Plugin for Dell Update
 )

# EXE-based uninstallers
$ExeUninstallers = @(
    # Update Plugins
    @{ Path='C:\ProgramData\Package Cache\{819b927b-a8d8-46a9-9512-0326900f80e3}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin 1' },
    @{ Path='C:\ProgramData\Package Cache\{31581d2d-a9e8-4f15-aa85-d6f9473b619e}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin 2' },
    @{ Path='C:\ProgramData\Package Cache\{9aec637d-a647-4f3b-998e-425f40e7dd50}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin 3' },
    @{ Path='C:\ProgramData\Package Cache\{3a267e2b-0948-4f12-a103-e2ac0461179d}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin 4' },
    @{ Path='C:\ProgramData\Package Cache\{EB4D8DD7-AE4C-442D-8D21-8BFB73C03748}\DellUpdateSupportAssistPlugin.exe'; Args='/uninstall /quiet'; Name='SupportAssist Update Plugin 5' },

    # Remediation Services
    @{ Path='C:\ProgramData\Package Cache\{3C7A4BC1-7C12-40A9-BE55-A4A2C1B415BD}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 1' },
    @{ Path='C:\ProgramData\Package Cache\{5F9CA6E9-C7D9-49C9-88FA-196D35D8EB82}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 2' },
    @{ Path='C:\ProgramData\Package Cache\{8CE1A5AE-856E-4B8E-A0E8-27DD7A209276}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 3' },
    @{ Path='C:\ProgramData\Package Cache\{96846915-505C-49A2-8AA0-63F90927DE87}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 4' },
    @{ Path='C:\ProgramData\Package Cache\{075EC656-5BD3-49B7-B0EE-07275A577C52}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 5' },
    @{ Path='C:\ProgramData\Package Cache\{A0D5BBDE-C013-48BA-B98A-CA0FF5CF36A6}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 6' },
    @{ Path='C:\ProgramData\Package Cache\{555298FA-14A9-48F2-A7A0-9602F31785DA}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 7' },
    @{ Path='C:\ProgramData\Package Cache\{34685541-A19E-4537-97C9-082238790346}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 8' },
    @{ Path='C:\ProgramData\Package Cache\{346EB8E9-AF99-485F-B39D-89717CB78F11}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 9' },
    @{ Path='C:\ProgramData\Package Cache\{DB72DCD5-BF99-4888-B104-CB605B82EC8A}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 10' },
    @{ Path='C:\ProgramData\Package Cache\{0B3F567C-A2EE-437A-861F-BB6DA9F2111B}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 11' },
    @{ Path='C:\ProgramData\Package Cache\{3563AA3A-C8AE-48D8-AB19-B1F359265295}\DellSupportAssistRemediationServiceInstaller.exe'; Args='/uninstall /quiet'; Name='Remediation Service 12' },

    # Agent & Others
    @{ Path='C:\Program Files\Dell\SupportAssistAgent\bin\SupportAssistUninstaller.exe'; Args='/S'; Name='SupportAssist Agent' },
    @{ Path='C:\Program Files\Dell\Dell Peripheral Manager\Uninstall.exe'; Args='/S'; Name='Peripheral Manager' },
    @{ Path='C:\Program Files\Dell\Dell Display Manager 2\uninst.exe'; Args='/S'; Name='Display Manager 2.X' }
)
#endregion

# Ensure C:\Temp exists
New-Item -Path 'C:\Temp' -ItemType Directory -Force | Out-Null

Function Write-Log {
    Param([string]$Message)
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))  $Message" |
      Out-File -FilePath $LogFile -Append -Encoding UTF8
}

Function Uninstall-MsiApp {
    Param([string]$ProductCode)
    $code = "{${ProductCode}}"
    Write-Log ("Checking for MSI {0}..." -f $code)
    $key1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode"
    $key2 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode"
    if (Test-Path $key1 -or Test-Path $key2) {
        Write-Log ("Found MSI {0}, uninstalling..." -f $code)
        try {
            $p = Start-Process msiexec.exe -ArgumentList "/x $code /qn /norestart" -Wait -NoNewWindow -PassThru
            if ($p.ExitCode -eq 0) {
                Write-Log ("SUCCESS: MSI {0} removed." -f $code)
            } else {
                Write-Log ("ERROR: MSI {0} exit code {1}" -f $code, $p.ExitCode)
            }
        } catch {
            Write-Log ("EXCEPTION uninstalling MSI {0}: {1}" -f $code, $_.Exception.Message)
        }
    } else {
        Write-Log ("Not installed: MSI {0}" -f $code)
    }
}

Function Uninstall-ExeApp {
    Param([string]$Path, [string]$Args, [string]$Name)
    if (Test-Path $Path) {
        Write-Log ("Found EXE [{0}], uninstalling..." -f $Name)
        try {
            $p = Start-Process -FilePath $Path -ArgumentList $Args -Wait -NoNewWindow -PassThru
            if ($p.ExitCode -eq 0) {
                Write-Log ("SUCCESS: {0} removed." -f $Name)
            } else {
                Write-Log ("ERROR: {0} exit code {1}" -f $Name, $p.ExitCode)
            }
        } catch {
            Write-Log ("EXCEPTION uninstalling EXE {0}: {1}" -f $Name, $_.Exception.Message)
        }
    } else {
        Write-Log ("Not found: {0} at {1}" -f $Name, $Path)
    }
}

Function Uninstall-RegistryDellApps {
    Write-Log "=== Registry-driven uninstall pass ==="
    $roots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    foreach ($root in $roots) {
        Get-ChildItem $root -ErrorAction SilentlyContinue | ForEach-Object {
            try { $app = Get-ItemProperty $_.PSPath -ErrorAction Stop } catch { return }
            if ($app.DisplayName -like '*Dell*' -and $app.UninstallString) {
                $name = $app.DisplayName; $cmd = $app.UninstallString.Trim('"')
                Write-Log ("Registry entry: {0}" -f $name)
                try {
                    if ($cmd -match 'msiexec') {
                        $args = ($cmd -replace '(^.*msiexec\.exe\s*)','') + ' /qn /norestart'
                        Start-Process msiexec.exe -ArgumentList $args -Wait -NoNewWindow
                    } else {
                        Start-Process cmd.exe -ArgumentList "/C `"$cmd /quiet`"" -Wait -NoNewWindow
                    }
                    Write-Log ("Removed: {0}" -f $name)
                } catch {
                    Write-Log ("ERROR removing {0}: {1}" -f $name, $_.Exception.Message)
                }
            }
        }
    }
}

Function Clean-DellTasksAndServices {
    Write-Log "=== Removing Dell scheduled tasks ==="
    Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -like '\Dell\*' -or $_.TaskName -like '*Dell*' } | ForEach-Object {
        Try {
            Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false
            Write-Log ("Task removed: {0}" -f $_.TaskName)
        } Catch {
            Write-Log ("ERROR removing task {0}: {1}" -f $_.TaskName, $_.Exception.Message)
        }
    }

    Write-Log "=== Stopping & deleting Dell services ==="
    Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Dell*' -or $_.DisplayName -like '*Dell*' } | ForEach-Object {
        Try {
            Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $_.Name -StartupType Disabled
            sc.exe delete $_.Name | Out-Null
            Write-Log ("Service deleted: {0}" -f $_.Name)
        } Catch {
            Write-Log ("ERROR cleaning service {0}: {1}" -f $_.Name, $_.Exception.Message)
        }
    }
}

# === Main Execution ===
Write-Log "=== Dell Bloatware removal START ==="
foreach ($guid in $DellGuids) { Uninstall-MsiApp -ProductCode $guid }
foreach ($entry in $ExeUninstallers) { Uninstall-ExeApp -Path $entry.Path -Args $entry.Args -Name $entry.Name }
Uninstall-RegistryDellApps
Clean-DellTasksAndServices
Write-Log "=== Dell Bloatware removal COMPLETE ==="
