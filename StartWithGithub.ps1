#!/usr/bin/env powershell
# ============================================================
# EXECUTIONPOLICY FOUNDATION - VOLLSTÄNDIGER GITHUB UPLOAD
# v2.0.0 | GrEEV.com KG | Optimiert für PS 5.1 + 7.5+
# ============================================================

param(
    [string]$GitUsername = "KonradLanz",
    [string]$GitEmail = "office@greev.com",
    [string]$TargetDir = "C:\Users\koni\ExecutionPolicy-Foundation",
    [string]$Language = "en",
    [switch]$SkipInstall = $false,
    [switch]$SkipAuth = $false,
    [switch]$DryRun = $false
)

# Initialize
$LASTEXITCODE = 0
$global:LASTEXITCODE = 0
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================
# LOCALIZATION (EN / DE)
# ============================================================

$Language = if ($Language -eq "de") { "de" } else { "en" }

$Strings = @{
    en = @{
        title                   = "ExecutionPolicy Foundation - Git Setup & GitHub Upload"
        subtitle                = "v2.0.0 | GrEEV.com KG | Support: support@greev.com"
        step_1                  = "[STEP 1/7] Checking dependencies..."
        step_2                  = "[STEP 2/7] Configuring Git..."
        step_3                  = "[STEP 3/7] GitHub authentication..."
        step_4                  = "[STEP 4/7] Setting up Git line endings..."
        step_5                  = "[STEP 5/7] Preparing working directory..."
        step_6                  = "[STEP 6/7] Creating Git commit and push..."
        step_7                  = "[STEP 7/7] Finalizing..."
        
        installing              = "Installing {0}..."
        already_installed       = "Already installed"
        git_installed           = "Git installed"
        github_cli_installed    = "GitHub CLI installed"
        checking_auth           = "Checking GitHub authentication..."
        need_token              = "GitHub token required"
        token_setup             = "Please set up GitHub authentication:"
        token_option_1          = "1. Run: gh auth login"
        token_option_2          = "2. Or set GH_TOKEN environment variable"
        token_info              = "After setup, run this script again"
        crlf_warning            = "Configuring Git line endings (CRLF warnings are normal on Windows)"
        git_user_set            = "Git User: {0}"
        git_email_set           = "Git Email: {0}"
        git_branch_set          = "Default Branch: main"
        skip_install_msg        = "Installation skipped (--SkipInstall)"
        skip_auth_msg           = "Authentication skipped (--SkipAuth)"
        antivirus_note          = "NOTE: Antivirus may flag this script. Add to whitelist if needed:"
        antivirus_avast         = "Avast: Settings > Exceptions > Add folder"
        antivirus_defender      = "Windows Defender: Settings > Virus & threat protection > Exclusions"
        working_dir_exists      = "Working directory exists: {0}"
        working_dir_created     = "Working directory created: {0}"
        git_repo_init           = "Initializing Git repository..."
        git_repo_exists         = "Git repository already exists"
        staging_files           = "[GIT] Staging all files..."
        creating_commit         = "[GIT] Creating commit..."
        pushing_repo            = "[GIT] Pushing to GitHub..."
        repo_exists             = "Repository already exists, pushing..."
        repo_created            = "Repository created and pushed"
        repo_creation_failed    = "Repository creation may have failed"
        no_changes              = "No changes to commit"
        dry_run_mode            = "[DRY-RUN] Push skipped"
        finished                = "FINISHED!"
        github_url              = "GitHub Repository:"
        opening_browser         = "Opening repository in browser..."
        support_info            = "Professional Support: support@greev.com | EUR 499/year"
        license_info            = "License: AGPL-3.0-or-later OR MIT"
        error_git_install       = "Git could not be installed!"
        error_git_missing       = "Git not found!"
    }
    de = @{
        title                   = "ExecutionPolicy Foundation - Git Setup & GitHub Upload"
        subtitle                = "v2.0.0 | GrEEV.com KG | Support: support@greev.com"
        step_1                  = "[SCHRITT 1/7] Abhängigkeiten überprüfen..."
        step_2                  = "[SCHRITT 2/7] Git konfigurieren..."
        step_3                  = "[SCHRITT 3/7] GitHub Authentifizierung..."
        step_4                  = "[SCHRITT 4/7] Git Zeilenumbruch konfigurieren..."
        step_5                  = "[SCHRITT 5/7] Arbeitsverzeichnis vorbereiten..."
        step_6                  = "[SCHRITT 6/7] Git Commit und Push..."
        step_7                  = "[SCHRITT 7/7] Abschluss..."
        
        installing              = "Installiere {0}..."
        already_installed       = "Bereits installiert"
        git_installed           = "Git installiert"
        github_cli_installed    = "GitHub CLI installiert"
        checking_auth           = "Überprüfe GitHub Authentifizierung..."
        need_token              = "GitHub Token erforderlich"
        token_setup             = "Bitte GitHub Authentifizierung einrichten:"
        token_option_1          = "1. Führe aus: gh auth login"
        token_option_2          = "2. Oder setze GH_TOKEN Umgebungsvariable"
        token_info              = "Nach dem Setup dieses Skript erneut ausführen"
        crlf_warning            = "Konfiguriere Git Zeilenumbrüche (CRLF-Warnungen sind normal unter Windows)"
        git_user_set            = "Git Benutzer: {0}"
        git_email_set           = "Git Email: {0}"
        git_branch_set          = "Standard Branch: main"
        skip_install_msg        = "Installation übersprungen (--SkipInstall)"
        skip_auth_msg           = "Authentifizierung übersprungen (--SkipAuth)"
        antivirus_note          = "HINWEIS: Antivirus könnte dieses Skript flaggen. Zur Whitelist hinzufügen:"
        antivirus_avast         = "Avast: Einstellungen > Ausnahmen > Ordner hinzufügen"
        antivirus_defender      = "Windows Defender: Einstellungen > Viren- und Bedrohungsschutz > Ausnahmen"
        working_dir_exists      = "Arbeitsverzeichnis existiert: {0}"
        working_dir_created     = "Arbeitsverzeichnis erstellt: {0}"
        git_repo_init           = "Initialisiere Git Repository..."
        git_repo_exists         = "Git Repository existiert bereits"
        staging_files           = "[GIT] Staging alle Dateien..."
        creating_commit         = "[GIT] Erstelle Commit..."
        pushing_repo            = "[GIT] Push zu GitHub..."
        repo_exists             = "Repository existiert bereits, pushe..."
        repo_created            = "Repository erstellt und gepusht"
        repo_creation_failed    = "Repository-Erstellung könnte fehlgeschlagen sein"
        no_changes              = "Keine Änderungen zum Commit"
        dry_run_mode            = "[DRY-RUN] Push übersprungen"
        finished                = "FERTIG!"
        github_url              = "GitHub Repository:"
        opening_browser         = "Öffne Repository im Browser..."
        support_info            = "Professional Support: support@greev.com | EUR 499/Jahr"
        license_info            = "Lizenz: AGPL-3.0-or-later OR MIT"
        error_git_install       = "Git konnte nicht installiert werden!"
        error_git_missing       = "Git nicht gefunden!"
    }
}

$Text = $Strings[$Language]

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan

# Calculate padding for dynamic box width
$boxWidth = 60
$titlePadded = $Text.title.PadRight($boxWidth - 4)
$subtitlePadded = $Text.subtitle.PadRight($boxWidth - 4)

Write-Host "║  $titlePadded  ║" -ForegroundColor Cyan
Write-Host "║  $subtitlePadded  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# ANTIVIRUS WARNING
# ============================================================

Write-Host $Text.antivirus_note -ForegroundColor Yellow
Write-Host "  • $($Text.antivirus_avast)" -ForegroundColor Gray
Write-Host "  • $($Text.antivirus_defender)" -ForegroundColor Gray
Write-Host ""

# ============================================================
# FUNCTIONS
# ============================================================

function Test-CommandExists {
    param([string]$Command)
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    return $null -ne $cmd
}

function Invoke-WingetInstall {
    param([string]$PackageId, [string]$PackageName)
    
    Write-Host "  $($Text.installing -f $PackageName)" -ForegroundColor Yellow
    
    & winget install $PackageId `
        --accept-package-agreements `
        --accept-source-agreements `
        -h 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠ Winget may have issues, continuing..." -ForegroundColor Yellow
    }
    
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Start-Sleep -Seconds 2
}

# ============================================================
# 1. INSTALLATION
# ============================================================

Write-Host $Text.step_1 -ForegroundColor Yellow
Write-Host ""

if (-not $SkipInstall) {
    if (-not (Test-CommandExists "git")) {
        Invoke-WingetInstall "Git.Git" "Git"
    } else {
        Write-Host "  ✓ $($Text.already_installed)" -ForegroundColor Green
    }
    
    if (Test-CommandExists "git") {
        $gitVersion = & git --version 2>&1
        Write-Host "  ✓ $($Text.git_installed): $gitVersion" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($Text.error_git_install)" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    if (-not (Test-CommandExists "gh")) {
        Invoke-WingetInstall "GitHub.cli" "GitHub CLI"
    } else {
        Write-Host "  ✓ $($Text.already_installed)" -ForegroundColor Green
    }
    
    if (Test-CommandExists "gh") {
        $ghVersion = & gh --version 2>&1
        Write-Host "  ✓ $($Text.github_cli_installed): $ghVersion" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ GitHub CLI $($Text.error_git_install)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ℹ $($Text.skip_install_msg)" -ForegroundColor Cyan
}

# ============================================================
# 2. GIT CONFIGURATION
# ============================================================

Write-Host ""
Write-Host $Text.step_2 -ForegroundColor Yellow

& git config --global user.name $GitUsername 2>&1 | Out-Null
& git config --global user.email $GitEmail 2>&1 | Out-Null
& git config --global init.defaultBranch main 2>&1 | Out-Null

Write-Host "  ✓ $($Text.git_user_set -f $GitUsername)" -ForegroundColor Green
Write-Host "  ✓ $($Text.git_email_set -f $GitEmail)" -ForegroundColor Green
Write-Host "  ✓ $($Text.git_branch_set)" -ForegroundColor Green

# ============================================================
# 3. GITHUB AUTHENTICATION
# ============================================================

Write-Host ""
Write-Host $Text.step_3 -ForegroundColor Yellow

if (Test-CommandExists "gh") {
    Write-Host "  $($Text.checking_auth)" -ForegroundColor Cyan
    $authStatus = & gh auth status 2>&1
    
    if ($LASTEXITCODE -ne 0 -and -not $SkipAuth) {
        Write-Host "  ⚠ $($Text.need_token)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  $($Text.token_setup):" -ForegroundColor Yellow
        Write-Host "    • $($Text.token_option_1)" -ForegroundColor Cyan
        Write-Host "    • $($Text.token_option_2)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  $($Text.token_info)" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    } elseif ($SkipAuth) {
        Write-Host "  ℹ $($Text.skip_auth_msg)" -ForegroundColor Cyan
    } else {
        Write-Host "  ✓ GitHub authenticated" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠ GitHub CLI not available" -ForegroundColor Yellow
}

# ============================================================
# 4. CONFIGURE GIT LINE ENDINGS (CRLF)
# ============================================================

Write-Host ""
Write-Host $Text.step_4 -ForegroundColor Yellow
Write-Host "  $($Text.crlf_warning)" -ForegroundColor Cyan

& git config --global core.safecrlf warn 2>&1 | Out-Null
& git config --global core.autocrlf true 2>&1 | Out-Null

Write-Host "  ✓ core.autocrlf = true" -ForegroundColor Green
Write-Host "  ✓ core.safecrlf = warn" -ForegroundColor Green

# ============================================================
# 5. PREPARE WORKING DIRECTORY
# ============================================================

Write-Host ""
Write-Host $Text.step_5 -ForegroundColor Yellow

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Write-Host "  ✓ $($Text.working_dir_created -f $TargetDir)" -ForegroundColor Green
} else {
    Write-Host "  ✓ $($Text.working_dir_exists -f $TargetDir)" -ForegroundColor Green
}

Push-Location $TargetDir

if (-not (Test-Path "$TargetDir\.git")) {
    Write-Host "  $($Text.git_repo_init)" -ForegroundColor Cyan
    & git init 2>&1 | Out-Null
    & git branch -M main 2>&1 | Out-Null
    Write-Host "  ✓ Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "  ✓ $($Text.git_repo_exists)" -ForegroundColor Green
}

# ============================================================
# CHECK/CREATE GITHUB REPOSITORY (BEFORE COMMIT!)
# ============================================================

$repoName = "ExecutionPolicy-Foundation"
Write-Host ""
Write-Host "  Checking GitHub repository..." -ForegroundColor Cyan

if (Test-CommandExists "gh") {
    $existingRepo = & gh repo view $repoName --json name 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Repository already exists on GitHub" -ForegroundColor Green
    } else {
        Write-Host "  ℹ Creating new repository on GitHub..." -ForegroundColor Yellow
        & gh repo create $repoName --public --source=. --remote=origin --description "Robust PowerShell execution framework with GPO detection and dual licensing" 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Repository created successfully" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Repository creation may have failed - continuing anyway" -ForegroundColor Yellow
        }
    }
}

# ============================================================
# 6. GIT COMMIT & PUSH
# ============================================================

Write-Host ""
Write-Host $Text.step_6 -ForegroundColor Yellow

$status = & git status --porcelain 2>&1
if ($status) {
    Write-Host "  $($Text.staging_files)" -ForegroundColor Cyan
    & git add . 2>&1 | Out-Null
    
    $commitMsg = @"
feat: ExecutionPolicy Foundation v2.0.0 - GrEEV.com KG

- Dual-licensed (AGPLv3 / MIT)
- Auto-unblock Zone.Identifier on PS files
- UTF-8 encoding support
- EN/DE localization
- PowerShell 5.1 + 7.5+ compatible
- Smart batch launcher with version detection
- GPO detection with actionable error messages
- Professional support: EUR 499/year

Support: support@greev.com
License: AGPL-3.0-or-later OR MIT
"@
    
    Write-Host "  $($Text.creating_commit)" -ForegroundColor Cyan
    & git commit -m $commitMsg 2>&1 | Out-Null
    
    if (-not $DryRun) {
        Write-Host "  $($Text.pushing_repo)" -ForegroundColor Cyan
        & git push -u origin main 2>&1 | Out-Null
        Write-Host "  ✓ Pushed to GitHub" -ForegroundColor Green
    } else {
        Write-Host "  $($Text.dry_run_mode)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ℹ $($Text.no_changes)" -ForegroundColor Cyan
}

# ============================================================
# 7. FINISHED
# ============================================================

Write-Host ""
Write-Host $Text.step_7 -ForegroundColor Yellow

Pop-Location

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    ✓ $($Text.finished) ✓                           ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if (Test-CommandExists "gh") {
    Write-Host "$($Text.github_url)" -ForegroundColor Cyan
    & gh repo view ExecutionPolicy-Foundation --json url -q '.url' 2>&1
    Write-Host ""
    Write-Host "$($Text.opening_browser)" -ForegroundColor Yellow
    & gh repo view ExecutionPolicy-Foundation --web 2>&1 | Out-Null
} else {
    Write-Host "$($Text.github_url)" -ForegroundColor Cyan
    Write-Host "  https://github.com/$GitUsername/ExecutionPolicy-Foundation" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Support & License:" -ForegroundColor Gray
Write-Host "  • $($Text.support_info)" -ForegroundColor Gray
Write-Host "  • $($Text.license_info)" -ForegroundColor Gray
Write-Host ""

$global:LASTEXITCODE = 0
exit 0
