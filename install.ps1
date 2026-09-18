<#
.SYNOPSIS
    OpenCode + Orca Two-Tier Multi-Agent Orchestration Installer (Windows PowerShell)

.DESCRIPTION
    Installs the orchestration contract, subagent definitions, and skills into
    the user's OpenCode and agent directories on Windows.

.PARAMETER DryRun
    Simulates the installation without modifying any files.

.PARAMETER Force
    Overwrites existing files without prompting.

.PARAMETER NoBackup
    Disables creating timestamped .bak backups of existing files.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -DryRun
    .\install.ps1 -Force
#>

[CmdletBinding()]
param (
    [switch]$DryRun,
    [switch]$Force,
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$targetConfigDir = Join-Path $HOME ".config\opencode"
$targetAgentDir = Join-Path $targetConfigDir "agent"
$targetSkillsDir = Join-Path $HOME ".agents\skills"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host @"

  ___  ____  _____ _   _  ____ ___  ____  _____ 
 / _ \|  _ \| ____| \ | |/ ___/ _ \|  _ \| ____|
| | | | |_) |  _| |  \| | |  | | | | | | |  _|  
| |_| |  __/| |___| |\  | |__| |_| | |_| | |___ 
 \___/|_|   |_____|_| \_|\____\___/|____/|_____|
  + Orca Two-Tier Multi-Agent Orchestration (Windows Installer)

"@ -ForegroundColor Cyan

Write-Host "==> Target Configuration Directory: $targetConfigDir" -ForegroundColor Blue
Write-Host "==> Target Skills Directory:        $targetSkillsDir" -ForegroundColor Blue

if ($DryRun) {
    Write-Host "[DRY-RUN MODE] No files will be modified or created." -ForegroundColor Yellow
}
Write-Host ""

function Deploy-File {
    param (
        [string]$src,
        [string]$dest
    )

    if (-not (Test-Path $src)) {
        Write-Error "Source file does not exist: $src"
        return
    }

    if (Test-Path $dest) {
        if (-not $NoBackup -and -not $DryRun) {
            $backupPath = "${dest}.bak_${timestamp}"
            Copy-Item -Path $dest -Destination $backupPath -Force
            Write-Host "  [Backup] $dest -> $backupPath" -ForegroundColor Yellow
        }
    }

    if ($DryRun) {
        Write-Host "  [dry-run] Would copy: $src -> $dest" -ForegroundColor Cyan
    } else {
        $parent = Split-Path -Parent $dest
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item -Path $src -Destination $dest -Force
        Write-Host "  [Installed] $dest" -ForegroundColor Green
    }
}

function Deploy-Directory {
    param (
        [string]$srcDir,
        [string]$destDir
    )

    if (-not (Test-Path $srcDir)) {
        Write-Error "Source directory does not exist: $srcDir"
        return
    }

    if ($DryRun) {
        Write-Host "  [dry-run] Would sync directory: $srcDir -> $destDir" -ForegroundColor Cyan
    } else {
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path "$srcDir\*" -Destination $destDir -Recurse -Force
        Write-Host "  [Synced Directory] $destDir" -ForegroundColor Green
    }
}

# 1. Directories
Write-Host "1. Preparing directories..." -ForegroundColor White
if (-not $DryRun) {
    if (-not (Test-Path $targetAgentDir)) { New-Item -ItemType Directory -Path $targetAgentDir -Force | Out-Null }
    if (-not (Test-Path $targetSkillsDir)) { New-Item -ItemType Directory -Path $targetSkillsDir -Force | Out-Null }
}
Write-Host "  Directories ready." -ForegroundColor Green

# 2. ORCHESTRATION.md
Write-Host "`n2. Deploying ORCHESTRATION.md..." -ForegroundColor White
Deploy-File (Join-Path $scriptDir "ORCHESTRATION.md") (Join-Path $targetConfigDir "ORCHESTRATION.md")

# 3. Subagents
Write-Host "`n3. Deploying Subagents (agent/)..." -ForegroundColor White
$agentFiles = Get-ChildItem -Path (Join-Path $scriptDir "agent") -Filter "*.md"
foreach ($file in $agentFiles) {
    Deploy-File $file.FullName (Join-Path $targetAgentDir $file.Name)
}

# 4. Skills
Write-Host "`n4. Deploying Specialized Skills (skills/)..." -ForegroundColor White
$skillDirs = Get-ChildItem -Path (Join-Path $scriptDir "skills") -Directory
foreach ($dir in $skillDirs) {
    Deploy-Directory $dir.FullName (Join-Path $targetSkillsDir $dir.Name)
}

# 5. opencode.jsonc
Write-Host "`n5. Configuring opencode.jsonc..." -ForegroundColor White
$destJsonc = Join-Path $targetConfigDir "opencode.jsonc"
if (Test-Path $destJsonc) {
    Write-Host "  Notice: $destJsonc already exists." -ForegroundColor Yellow
    $content = Get-Content -Path $destJsonc -Raw
    if ($content -match "ORCHESTRATION\.md") {
        Write-Host "  Verified: ORCHESTRATION.md is already referenced in instructions." -ForegroundColor Green
    } else {
        Write-Host "  Action required: Ensure '$targetConfigDir\ORCHESTRATION.md' is in your 'instructions' array in opencode.jsonc." -ForegroundColor Yellow
        Deploy-File (Join-Path $scriptDir "opencode.jsonc") (Join-Path $targetConfigDir "opencode.jsonc.template")
    }
} else {
    Deploy-File (Join-Path $scriptDir "opencode.jsonc") $destJsonc
}

# 6. Check Dependencies
Write-Host "`n6. Checking System Dependencies..." -ForegroundColor White
if (Get-Command "opencode" -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] OpenCode CLI detected." -ForegroundColor Green
} else {
    Write-Host "  [!] OpenCode CLI not found in PATH." -ForegroundColor Yellow
    Write-Host "      Install via: npm install -g opencode-ai or bun add -g opencode-ai"
}

if (Get-Command "orca" -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] Orca CLI detected." -ForegroundColor Green
} else {
    Write-Host "  [i] Orca CLI not detected in PATH." -ForegroundColor DarkGray
    Write-Host "      Orca is used for Tier 1 floating dispatcher handoffs." -ForegroundColor DarkGray
}

Write-Host "`n==============================================================" -ForegroundColor Green
Write-Host "Installation Complete! Setup is ready to use." -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "`nTo start your lead project orchestrator:"
Write-Host "  opencode --model openai/gpt-5.6-sol`n" -ForegroundColor Cyan
