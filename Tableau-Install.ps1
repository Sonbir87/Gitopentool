
# Tableau Desktop | Sequential Silent Installation
# No forced reboot | No user interaction
# Logs: C:\Temp\Tableau-Install.log

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Source = 'C:\Users\sonbir.kumar\Downloads'
$LogDir = 'C:\Temp'
$Log = Join-Path $LogDir 'Tableau-Install.log'

New-Item -Path $LogDir -ItemType Directory -Force | Out-Null

$Installers = @(
    'TableauDesktop-64bit-2023-3-23.exe'
    'TableauDesktop-64bit-2024-2-24.exe'
    'TableauDesktop-64bit-2025-3-10.exe'
    'TableauDesktop-64bit-2026-2-3.EXE'
)

function Write-Log {
    param([string]$Message)

    $Line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | $Message"
    Write-Output $Line
    Add-Content -LiteralPath $Log -Value $Line -Encoding UTF8
}

Write-Log '===== Tableau installation started ====='

foreach ($Installer in $Installers) {

    $Path = Join-Path $Source $Installer

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Log "MISSING: $Installer"
        continue
    }

    Write-Log "Starting installation: $Installer"

    try {
        # Tableau Desktop silent installer
        $Process = Start-Process `
            -FilePath $Path `
            -ArgumentList '/quiet', '/norestart', 'ACCEPTEULA=1' `
            -Wait `
            -PassThru

        Write-Log "Completed: $Installer | ExitCode=$($Process.ExitCode)"

        if ($Process.ExitCode -eq 0) {
            Write-Log "SUCCESS: $Installer"
        }
        elseif ($Process.ExitCode -eq 3010) {
            Write-Log "SUCCESS: $Installer | Restart required but not initiated"
        }
        else {
            Write-Log "FAILED: $Installer | ExitCode=$($Process.ExitCode)"
        }
    }
    catch {
        Write-Log "ERROR: $Installer | $($_.Exception.Message)"
    }
}

Write-Log '===== Tableau installation verification ====='

$RegPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$Installed = @(
    Get-ItemProperty $RegPaths -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -match '^Tableau 20\d{2}\.' } |
    Sort-Object DisplayName -Unique
)

foreach ($App in $Installed) {
    Write-Log "INSTALLED: $($App.DisplayName) | $($App.DisplayVersion)"
}

Write-Log '===== Tableau installation completed ====='
