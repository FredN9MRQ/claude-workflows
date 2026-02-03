# setup-symlinks.ps1
# Auto-discovers and sets up symlinks to shared Claude commands
# Works on: Windows PowerShell

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Path to the shared commands directory.")]
    [string]$SharedCommands = "$env:USERPROFILE\claude-shared\commands",

    [Parameter(HelpMessage="Root path to search for projects. Defaults to user profile.")]
    [string]$SearchPath = $env:USERPROFILE,

    [Parameter(HelpMessage="Switch to search the entire C:\ drive.")]
    [switch]$SearchAll,

    [Parameter(HelpMessage="Switch to bypass the confirmation prompt and apply changes.")]
    [switch]$Force
)

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-Step { param([string]$Message) Write-Host "`n==> $Message" -ForegroundColor $Cyan }
function Write-Success { param([string]$Message) Write-Host "  ✓ $Message" -ForegroundColor $Green }
function Write-Warning { param([string]$Message) Write-Host "  ⚠ $Message" -ForegroundColor $Yellow }
function Write-Error { param([string]$Message) Write-Host "  ✗ $Message" -ForegroundColor $Red }

# Check for admin privileges (required for symlinks on Windows)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "This script requires Administrator privileges to create symlinks."
    Write-Host "Please run PowerShell as Administrator and try again.`n"
    exit 1
}

Write-Step "Claude Commands Symlink Auto-Setup"

if ($SearchAll) {
    $SearchPath = "C:\"
}

Write-Host "Shared commands path: $SharedCommands"
Write-Host "Project search path:  $SearchPath"
Write-Host ""

# Check if shared commands folder exists
if (-not (Test-Path $SharedCommands)) {
    Write-Error "Shared commands folder not found at $SharedCommands"
    Write-Host "Please create it first and add your command files (.md)."
    exit 1
}

# List command files
Write-Host "Available shared commands:" -ForegroundColor $Blue
$sharedCommandFiles = Get-ChildItem "$SharedCommands\*.md"
if ($sharedCommandFiles) {
    $sharedCommandFiles | ForEach-Object { Write-Host "  - $($_.Name)" }
} else {
    Write-Warning "No command files (.md) found in shared commands folder."
}
Write-Host ""

# Auto-discover .claude folders
Write-Step "Searching for Claude Code projects..."
Write-Host "(This may take a moment, depending on the search path)"
Write-Host ""

# Find all .claude directories, excluding the global one and claude-shared
$claudeDirs = @()
Get-ChildItem -Path $SEARCH_ROOT -Directory -Recurse -Filter ".claude" -ErrorAction SilentlyContinue | ForEach-Object {
    $claudePath = $_.FullName
    $projectPath = Split-Path $claudePath -Parent

    # Skip if it's the global .claude config in home directory
    if ($claudePath -eq "$env:USERPROFILE\.claude") {
        return
    }

    # Skip if it's inside claude-shared
    if ($claudePath -like "*claude-shared*") {
        return
    }

    $claudeDirs += $projectPath
}

# Show discovered projects
if ($claudeDirs.Count -eq 0) { 
    Write-Warning "No Claude Code projects found in '$SearchPath'."
    Write-Host ""
    Write-Host "Claude Code projects have a .claude folder in their root."
    Write-Host "Start Claude Code in a project directory to create one."
    exit 0
}

Write-Host "Found $($claudeDirs.Count) Claude Code project(s):" -ForegroundColor Green
foreach ($project in $claudeDirs) {
    $commandsPath = Join-Path $project ".claude\commands"

    # Check if already has symlink
    if (Test-Path $commandsPath) {
        $item = Get-Item $commandsPath
        if ($item.Attributes -match "ReparsePoint") {
            $target = $item.Target
            if ($target -eq $SharedCommands) {
                Write-Host "  " -NoNewline
                Write-Host "✓" -ForegroundColor Green -NoNewline
                Write-Host " $project " -NoNewline
                Write-Host "(already linked)" -ForegroundColor Blue
            } else {
                Write-Host "  " -NoNewline
                Write-Host "⚠" -ForegroundColor Yellow -NoNewline
                Write-Host " $project " -NoNewline
                Write-Host "(has different symlink)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  " -NoNewline
            Write-Host "○" -ForegroundColor Yellow -NoNewline
            Write-Host " $project " -NoNewline
            Write-Host "(needs setup)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  " -NoNewline
        Write-Host "○" -ForegroundColor Yellow -NoNewline
        Write-Host " $project " -NoNewline
        Write-Host "(needs setup)" -ForegroundColor Yellow
    }
}
Write-Host ""

# Ask for confirmation
if (-not $Force) {
    $response = Read-Host "Proceed with setting up symlinks for all 'needs setup' projects? [y/N]"
    if ($response -notmatch '^[Yy]$') {
        Write-Host "`nOperation cancelled by user." -ForegroundColor $Yellow
        exit 0
    }
}

Write-Host ""

# Process each project
$successCount = 0
$skipCount = 0
$failCount = 0

foreach ($project in $claudeDirs) {
    Write-Host "Processing: $project" -ForegroundColor $Blue

    $claudeDir = Join-Path $project ".claude"
    $commandsPath = Join-Path $claudeDir "commands"

    # Check if already correctly symlinked
    if (Test-Path $commandsPath) {
        $item = Get-Item $commandsPath
        if ($item.Attributes -match "ReparsePoint") {
            if ($item.Target -eq $SharedCommands) {
                Write-Host "  ⊙ Already correctly linked, skipping." -ForegroundColor $Blue
                $skipCount++
                Write-Host ""
                continue
            }
        }
    } 

    # Check if project exists
    if (-not (Test-Path $project)) {
        Write-Error "Project directory not accessible, skipping."
        $failCount++
        Write-Host ""
        continue
    }

    # Create .claude directory if it doesn't exist
    if (-not (Test-Path $claudeDir)) {
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }

    # Backup existing commands if not a symlink
    if (Test-Path $commandsPath) {
        $item = Get-Item $commandsPath
        if ($item.Attributes -notmatch "ReparsePoint") {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupName = "commands.backup.$timestamp"
            $backupPath = Join-Path $claudeDir $backupName
            Move-Item -Path $commandsPath -Destination $backupPath -Force
            Write-Host "  - Backed up existing 'commands' directory to '$backupName'."
        } else {
            Remove-Item -Path $commandsPath -Force -Recurse
            Write-Host "  - Removed old/incorrect symlink."
        }
    }

    # Create symlink
    try {
        New-Item -ItemType SymbolicLink -Path $commandsPath -Target $SharedCommands -Force | Out-Null

        # Verify symlink
        $newItem = Get-Item $commandsPath -Force
        if (($newItem.Attributes -match "ReparsePoint") -and ($newItem.Target -eq $SharedCommands)) {
            Write-Success "Symlink created successfully."
            $successCount++
        } else {
            Write-Error "Failed to create or verify symlink."
            $failCount++
        }
    } catch {
        Write-Error "An exception occurred while creating symlink: $($_.Exception.Message)"
        $failCount++
    }

    Write-Host ""
}

Write-Step "Setup Complete"
Write-Host "✓ Success: $successCount project(s) linked." -ForegroundColor $Green
if ($skipCount -gt 0) {
    Write-Host "⊙ Skipped: $skipCount project(s) (already linked)." -ForegroundColor $Blue
}
if ($failCount -gt 0) {
    Write-Host "✗ Failed:  $failCount project(s) (see errors above)." -ForegroundColor $Red
}
Write-Host "`nYour commands are now synced across all processed projects.`n" -ForegroundColor $Green
