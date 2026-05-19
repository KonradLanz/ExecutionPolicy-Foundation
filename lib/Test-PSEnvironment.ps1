# Test-PSEnvironment.ps1
# Baseline: PowerShell 5.1 (ships with Windows 10/11, no install required)
# For scripts requiring PS 7+: use pwsh.exe and name the script *.pwsh7.ps1
#
# Naming convention:
#   *.ps1          -> PS 5.1 compatible (default baseline)
#   *.pwsh7.ps1    -> Requires pwsh.exe >= 7.x (must be installed separately)
#   *.pwsh74.ps1   -> Requires pwsh.exe >= 7.4 (LTS)
#
# Usage in any script:
#   . (Join-Path $PSScriptRoot '../lib/Test-PSEnvironment.ps1')
#   Test-PSEnvironment

function Test-PSEnvironment {
    param(
        [version]$MinimumVersion    = [version]'5.1',
        [version]$RecommendedVersion = [version]'7.4',
        [switch]$RequirePS7,
        [switch]$Quiet
    )

    $cur     = $PSVersionTable.PSVersion
    $edition = $PSVersionTable.PSEdition   # Desktop=5.x, Core=7.x
    $os      = [System.Environment]::OSVersion.Version
    $isPS7   = $cur.Major -ge 7
    $isPS51  = ($edition -eq 'Desktop') -and ($cur.Major -eq 5)

    if (-not $Quiet) {
        Write-Host "PowerShell : $cur ($edition)" -ForegroundColor Cyan
        Write-Host "Windows    : $os" -ForegroundColor Cyan
    }

    # Hard stop if script explicitly needs PS7
    if ($RequirePS7 -and -not $isPS7) {
        Write-Host '' 
        Write-Host '[FEHLER] Dieses Skript benoetigt pwsh.exe >= 7.x (PowerShell Core).' -ForegroundColor Red
        Write-Host '         Aktuell: powershell.exe ' -NoNewline -ForegroundColor Red
        Write-Host $cur -ForegroundColor Yellow
        Write-Host '         Installieren: winget install Microsoft.PowerShell' -ForegroundColor Gray
        Write-Host '         Dann neu starten mit: pwsh.exe' -ForegroundColor Gray
        exit 1
    }

    # Hard stop below minimum
    if ($cur -lt $MinimumVersion) {
        Write-Host ''
        Write-Host "[FEHLER] PowerShell $cur zu alt. Mindestens $MinimumVersion erforderlich." -ForegroundColor Red
        exit 1
    }

    # Soft hint for recommended
    if ($cur -lt $RecommendedVersion -and -not $Quiet) {
        Write-Host ''
        Write-Host "[HINWEIS] PS $cur gefunden. Empfohlen: PS $RecommendedVersion+ fuer alle Features." -ForegroundColor Yellow
        Write-Host '          winget install Microsoft.PowerShell' -ForegroundColor Gray
    }

    # winget
    $hasWinget = [bool](Get-Command winget -ErrorAction SilentlyContinue)
    if (-not $hasWinget -and -not $Quiet) {
        Write-Host ''
        Write-Host '[HINWEIS] winget nicht gefunden. Manche Bootstrap-Schritte schlagen fehl.' -ForegroundColor Yellow
        Write-Host '          https://aka.ms/getwinget' -ForegroundColor Gray
    }

    # git
    $hasGit = [bool](Get-Command git -ErrorAction SilentlyContinue)
    if (-not $hasGit -and -not $Quiet) {
        Write-Host ''
        Write-Host '[HINWEIS] git nicht gefunden.' -ForegroundColor Yellow
        Write-Host '          winget install Git.Git' -ForegroundColor Gray
    }

    # Windows Terminal (optional, no blocker)
    $hasWT = [bool](Get-Command wt -ErrorAction SilentlyContinue)
    if (-not $hasWT -and -not $Quiet) {
        Write-Host ''
        Write-Host '[HINWEIS] Windows Terminal nicht gefunden (empfohlen, kein Blocker).' -ForegroundColor Gray
        Write-Host '          winget install Microsoft.WindowsTerminal' -ForegroundColor Gray
    }

    return [pscustomobject]@{
        PSVersion    = $cur
        PSEdition    = $edition
        IsPS7Plus    = $isPS7
        IsPS51       = $isPS51
        OSVersion    = $os
        HasWinget    = $hasWinget
        HasGit       = $hasGit
        HasWT        = $hasWT
    }
}
