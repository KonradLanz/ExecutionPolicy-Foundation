#!/usr/bin/env pwsh
# ============================================================
# STARTWITHGITHUB - AUTOMATED GITHUB REPOSITORY SETUP
# v2.1.0 | GrEEV.com KG | support@greev.com
#
# Automatically create GitHub repo and push commits
# Features:
#   - Check if repository exists
#   - Create repository if needed
#   - Configure Git settings
#   - Push commits to GitHub
# ============================================================

param(
    [string]$Language = "en",
    [switch]$SkipInstall = $false,
    [switch]$Force = $false
)

$Language = if ($Language -eq "de") { "de" } else { "en" }

# ============================================================
# LOCALIZATION
# ============================================================

$Strings = @{
    en = @{
        title                  = "GitHub Repository Setup & Upload"
        version                = "v2.1.0 | GrEEV.com KG"
        
        # Main sections
        step_check_deps        = "Checking dependencies"
        step_configure_git     = "Configuring Git"
        step_check_github      = "Checking GitHub authentication"
        step_check_repo        = "Checking repository status"
        step_create_repo       = "Creating GitHub repository"
        step_commit_push       = "Creating commits and pushing"
        step_finalize          = "Finalizing setup"
        
        # Repository status checks
        repo_exists            = "Repository already exists on GitHub"
        repo_not_exists        = "Repository does not exist - will be created"
        repo_creating          = "Creating repository on GitHub"
        repo_created           = "Repository created successfully"
        repo_error             = "Error creating repository"
        
        # Status messages
        success                = "Success"
        error                  = "Error"
        warning                = "Warning"
        info                   = "Info"
        
        # Completion
        finished               = "FINISHED!"
        completed              = "Script completed successfully"
        support                = "Professional Support"
    }
    de = @{
        title                  = "GitHub Repository Setup & Upload"
        version                = "v2.1.0 | GrEEV.com KG"
        
        # Main sections
        step_check_deps        = "Überprüfe Abhängigkeiten"
        step_configure_git     = "Git konfigurieren"
        step_check_github      = "GitHub-Authentifizierung überprüfen"
        step_check_repo        = "Repository-Status überprüfen"
        step_create_repo       = "GitHub Repository erstellen"
        step_commit_push       = "Commits erstellen und pushen"
        step_finalize          = "Setup abschließen"
        
        # Repository status checks
        repo_exists            = "Repository existiert bereits auf GitHub"
        repo_not_exists        = "Repository existiert nicht - wird erstellt"
        repo_creating          = "Erstelle Repository auf GitHub"
        repo_created           = "Repository erfolgreich erstellt"
        repo_error             = "Fehler beim Erstellen des Repository"
        
        # Status messages
        success                = "Erfolg"
        error                  = "Fehler"
        warning                = "Warnung"
        info                   = "Info"
        
        # Completion
        finished               = "FERTIG!"
        completed              = "Skript erfolgreich abgeschlossen"
        support                = "Professioneller Support"
    }
}

$Text = $Strings[$Language]

# ============================================================
# UTILITIES
# ============================================================

function Show-Header {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $($Text.title)" -ForegroundColor Cyan
    Write-Host "║  $($Text.version)" -ForegroundColor Cyan
    Write-Host "║  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Footer {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    ✓ $($Text.finished)                           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Test-Command {
    param([string]$Command)
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    } catch {
        return $false
    }
}

function Get-RepoName {
    # Get repo name from git remote origin
    try {
        $remoteUrl = git config --get remote.origin.url
        if ($remoteUrl) {
            $repoName = [System.IO.Path]::GetFileNameWithoutExtension($remoteUrl)
            return $repoName
        }
    } catch { }
    
    # Fallback: use folder name
    return Split-Path -Leaf (Get-Location).Path
}

function Get-GitHubUser {
    # Try to get username from git config
    try {
        $user = git config --get user.name
        if ($user) { return $user }
    } catch { }
    
    # Try gh CLI
    try {
        $whoami = gh api user --jq '.login' 2>$null
        if ($whoami) { return $whoami }
    } catch { }
    
    return $null
}

function Test-RepositoryExists {
    param(
        [string]$Owner,
        [string]$RepoName
    )
    
    try {
        $result = gh repo view "$Owner/$RepoName" --json name 2>$null
        return $?
    } catch {
        return $false
    }
}

function Create-Repository {
    param(
        [string]$RepoName,
        [bool]$Private = $true
    )
    
    try {
        Write-Host "  ℹ $($Text.repo_creating)..." -ForegroundColor Yellow
        
        $visibility = if ($Private) { "--private" } else { "--public" }
        
        # Create repo on GitHub
        gh repo create $RepoName $visibility --source=. --remote=origin --push 2>&1 | Out-Null
        
        if ($?) {
            Write-Host "  ✓ $($Text.repo_created)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ✗ $($Text.repo_error)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  ✗ $($Text.repo_error): $_" -ForegroundColor Red
        return $false
    }
}

# ============================================================
# MAIN WORKFLOW
# ============================================================

Show-Header

# STEP 1: Check dependencies
Write-Host "[STEP 1/7] $($Text.step_check_deps)..." -ForegroundColor Cyan
Write-Host ""

if (Test-Command "git") {
    Write-Host "  ✓ Git installed: $(git --version)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Git not found!" -ForegroundColor Red
    exit 1
}

if (Test-Command "gh") {
    Write-Host "  ✓ GitHub CLI installed: $(gh --version | Select-Object -First 1)" -ForegroundColor Green
} else {
    Write-Host "  ✗ GitHub CLI not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# STEP 2: Configure Git
Write-Host "[STEP 2/7] $($Text.step_configure_git)..." -ForegroundColor Cyan
Write-Host ""

try {
    $gitUser = git config --get user.name
    $gitEmail = git config --get user.email
    
    Write-Host "  ✓ Git User: $gitUser"
    Write-Host "  ✓ Git Email: $gitEmail"
    Write-Host "  ✓ Default Branch: $(git rev-parse --abbrev-ref HEAD)"
} catch {
    Write-Host "  ✗ Error reading Git config" -ForegroundColor Red
}

Write-Host ""

# STEP 3: Check GitHub authentication
Write-Host "[STEP 3/7] $($Text.step_check_github)..." -ForegroundColor Cyan
Write-Host "  Checking GitHub authentication..."

try {
    $ghUser = gh auth status 2>&1
    if ($?) {
        Write-Host "  ✓ GitHub authenticated" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Not authenticated - please run: gh auth login" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ✗ Authentication check failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# STEP 4: Check Git line endings
Write-Host "[STEP 4/7] Setting up Git line endings..." -ForegroundColor Cyan
Write-Host "  Configuring Git line endings (CRLF warnings are normal on Windows)"

try {
    git config core.autocrlf true
    git config core.safecrlf warn
    Write-Host "  ✓ core.autocrlf = true"
    Write-Host "  ✓ core.safecrlf = warn"
} catch {
    Write-Host "  ✗ Error configuring line endings" -ForegroundColor Red
}

Write-Host ""

# STEP 5: Prepare working directory
Write-Host "[STEP 5/7] Preparing working directory..." -ForegroundColor Cyan
Write-Host ""

$workDir = (Get-Location).Path
Write-Host "  ✓ Working directory exists: $workDir"

if (Test-Path ".git") {
    Write-Host "  ✓ Git repository already exists"
} else {
    Write-Host "  ⚠ Git repository not initialized" -ForegroundColor Yellow
}

Write-Host ""

# STEP 6: Check and create repository on GitHub
Write-Host "[STEP 6/7] $($Text.step_check_repo)..." -ForegroundColor Cyan
Write-Host ""

$repoName = Get-RepoName
$gitHubUser = Get-GitHubUser

if ($gitHubUser) {
    Write-Host "  GitHub User: $gitHubUser"
    Write-Host "  Repository Name: $repoName"
    Write-Host ""
    
    # Check if repo exists
    if (Test-RepositoryExists -Owner $gitHubUser -RepoName $repoName) {
        Write-Host "  ✓ $($Text.repo_exists)" -ForegroundColor Green
        Write-Host ""
        Write-Host "[STEP 7/7] Pushing commits..." -ForegroundColor Cyan
        Write-Host ""
        
        try {
            git push -u origin main 2>&1 | Out-Null
            if ($?) {
                Write-Host "  ✓ Commits pushed successfully" -ForegroundColor Green
            } else {
                Write-Host "  ℹ No changes to commit (repository up to date)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  ✗ Error pushing commits: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  ℹ $($Text.repo_not_exists)" -ForegroundColor Yellow
        Write-Host ""
        
        if (Create-Repository -RepoName $repoName -Private $true) {
            Write-Host ""
            Write-Host "[STEP 7/7] Repository created!" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "[STEP 7/7] Failed to create repository" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "  ✗ Could not determine GitHub username" -ForegroundColor Red
    Write-Host "  Please run: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Final message
Write-Host "[STEP 7/7] $($Text.step_finalize)..." -ForegroundColor Cyan
Write-Host ""

Show-Footer

Write-Host "GitHub Repository:" -ForegroundColor Green
Write-Host "  https://github.com/$gitHubUser/$repoName"
Write-Host ""

Write-Host "$($Text.support):" -ForegroundColor Cyan
Write-Host "  • Email: support@greev.com | EUR 499/year"
Write-Host "  • License: AGPL-3.0-or-later OR MIT"
Write-Host ""

Write-Host "============================================================"
Write-Host "[OK] $($Text.completed)"
Write-Host "============================================================"
Write-Host ""