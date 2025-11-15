# setup-symlinks.ps1
# Auto-discovers and sets up symlinks to shared Claude commands
# Works on: Windows PowerShell

Write-Host "`nClaude Commands Symlink Auto-Setup" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""

# Shared commands location
$SHARED_COMMANDS = "$env:USERPROFILE\claude-shared\commands"
$DEFAULT_SEARCH = $env:USERPROFILE
$ROOT_SEARCH = "C:\"

Write-Host "Shared commands: $SHARED_COMMANDS"
Write-Host ""

# Ask if they want to search entire drive
$searchChoice = Read-Host "Search entire C:\ drive? (slower but thorough) [y/N]"
if ($searchChoice -match '^[Yy]$') {
    $SEARCH_ROOT = $ROOT_SEARCH
    Write-Host "Searching entire drive: $SEARCH_ROOT" -ForegroundColor Blue
} else {
    $SEARCH_ROOT = $DEFAULT_SEARCH
    Write-Host "Searching user directory: $SEARCH_ROOT" -ForegroundColor Blue
}
Write-Host ""

# Check if shared commands folder exists
if (-not (Test-Path $SHARED_COMMANDS)) {
    Write-Host "ERROR: Shared commands folder not found at $SHARED_COMMANDS" -ForegroundColor Red
    Write-Host "Please create it first and add your command files (.md)"
    exit 1
}

# List command files
Write-Host "Available commands:" -ForegroundColor Blue
Get-ChildItem "$SHARED_COMMANDS\*.md" | ForEach-Object { Write-Host "  $($_.Name)" }
Write-Host ""

# Auto-discover .claude folders
Write-Host "Searching for Claude Code projects..." -ForegroundColor Blue
Write-Host "(This may take a moment)"
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
    Write-Host "No Claude Code projects found." -ForegroundColor Yellow
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
            if ($target -like "*claude-shared\commands*") {
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

# Check for admin privileges (required for symlinks on Windows)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges to create symlinks." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again.`n"
    exit 1
}

# Ask for confirmation
$response = Read-Host "Set up symlinks for all projects? [y/N]"
if ($response -notmatch '^[Yy]$') {
    Write-Host "Cancelled."
    exit 0
}

Write-Host ""

# Process each project
$successCount = 0
$skipCount = 0
$failCount = 0

foreach ($project in $claudeDirs) {
    Write-Host "Processing: $project" -ForegroundColor Yellow

    $claudeDir = Join-Path $project ".claude"
    $commandsPath = Join-Path $claudeDir "commands"

    # Check if already correctly symlinked
    if (Test-Path $commandsPath) {
        $item = Get-Item $commandsPath
        if ($item.Attributes -match "ReparsePoint") {
            $target = $item.Target
            if ($target -like "*claude-shared\commands*") {
                Write-Host "  ⊙ Already correctly linked, skipping" -ForegroundColor Blue
                $skipCount++
                Write-Host ""
                continue
            }
        }
    }

    # Check if project exists
    if (-not (Test-Path $project)) {
        Write-Host "  ✗ Project directory not accessible, skipping" -ForegroundColor Red
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
            Move-Item $commandsPath $backupPath -Force
            Write-Host "  - Backed up existing commands to $backupName"
        } else {
            Remove-Item $commandsPath -Force
            Write-Host "  - Removed old symlink"
        }
    }

    # Create symlink
    try {
        New-Item -ItemType SymbolicLink -Path $commandsPath -Target $SHARED_COMMANDS -Force | Out-Null

        # Verify symlink
        if ((Test-Path $commandsPath) -and ((Get-Item $commandsPath).Attributes -match "ReparsePoint")) {
            Write-Host "  ✓ Symlink created successfully" -ForegroundColor Green
            Write-Host "  - Commands available:"
            Get-ChildItem "$commandsPath\*.md" | ForEach-Object { Write-Host "    $($_.Name)" }
            $successCount++
        } else {
            Write-Host "  ✗ Failed to create symlink" -ForegroundColor Red
            $failCount++
        }
    } catch {
        Write-Host "  ✗ Failed to create symlink: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }

    Write-Host ""
}

# Summary
Write-Host "===================================="
Write-Host "✓ Success: $successCount project(s)" -ForegroundColor Green
if ($skipCount -gt 0) {
    Write-Host "⊙ Skipped: $skipCount project(s) (already linked)" -ForegroundColor Blue
}
if ($failCount -gt 0) {
    Write-Host "✗ Failed: $failCount project(s)" -ForegroundColor Red
}
Write-Host "`nDone! Your commands are now synced across all projects.`n"
