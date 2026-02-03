# Pterodactyl Hytale Server Fix Script
# This script diagnoses and fixes the Hytale server issues

$API_KEY = "ptlc_xEl0i8zwohLvizEC503CgkVRGPBNUnPKdMfIujIi0gj"
$PANEL_URL = "http://10.0.10.45"
$SERVER_ID = "415ef753-aa42-4c33-ae12-bbcc44d971f7"

$headers = @{
    "Authorization" = "Bearer $API_KEY"
    "Accept" = "application/json"
    "Content-Type" = "application/json"
}

Write-Host "=== Pterodactyl Hytale Server Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

# Function to send command to server
function Send-ServerCommand {
    param([string]$command)

    $body = @{
        command = $command
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "$PANEL_URL/api/client/servers/$SERVER_ID/command" -Method POST -Headers $headers -Body $body
        Write-Host "✓ Sent command: $command" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to send command: $command" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to list files
function Get-ServerFiles {
    param([string]$path = "/")

    try {
        $response = Invoke-RestMethod -Uri "$PANEL_URL/api/client/servers/$SERVER_ID/files/list?directory=$path" -Method GET -Headers $headers
        return $response.data
    } catch {
        Write-Host "✗ Failed to list files in $path" -ForegroundColor Red
        return $null
    }
}

# Function to get file contents
function Get-FileContents {
    param([string]$file)

    try {
        $response = Invoke-RestMethod -Uri "$PANEL_URL/api/client/servers/$SERVER_ID/files/contents?file=$file" -Method GET -Headers $headers
        return $response
    } catch {
        Write-Host "✗ Failed to read file: $file" -ForegroundColor Red
        return $null
    }
}

# Function to delete file/directory
function Remove-ServerFile {
    param([string]$path)

    $body = @{
        root = "/"
        files = @($path)
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "$PANEL_URL/api/client/servers/$SERVER_ID/files/delete" -Method POST -Headers $headers -Body $body
        Write-Host "✓ Deleted: $path" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "✗ Failed to delete: $path" -ForegroundColor Red
        return $false
    }
}

Write-Host "Step 1: Checking root directory contents..." -ForegroundColor Yellow
$rootFiles = Get-ServerFiles "/"
if ($rootFiles) {
    Write-Host "Files in root directory:" -ForegroundColor Cyan
    foreach ($file in $rootFiles) {
        $type = if ($file.is_file) { "FILE" } else { "DIR " }
        Write-Host "  [$type] $($file.name) - $($file.size) bytes, modified: $($file.modified_at)"
    }
    Write-Host ""
}

Write-Host "Step 2: Checking HytaleAssets directory..." -ForegroundColor Yellow
$hytaleAssets = $rootFiles | Where-Object { $_.name -eq "HytaleAssets" }
if ($hytaleAssets) {
    Write-Host "✓ HytaleAssets directory exists" -ForegroundColor Green

    # Check for manifest.json
    $assetFiles = Get-ServerFiles "/HytaleAssets"
    if ($assetFiles) {
        $manifest = $assetFiles | Where-Object { $_.name -eq "manifest.json" }
        if ($manifest) {
            Write-Host "✓ manifest.json exists in HytaleAssets" -ForegroundColor Green

            # Try to read it
            Write-Host "  Reading manifest.json..." -ForegroundColor Cyan
            $manifestContent = Get-FileContents "/HytaleAssets/manifest.json"
            if ($manifestContent) {
                Write-Host "  Content preview:" -ForegroundColor Cyan
                Write-Host "  $($manifestContent.Substring(0, [Math]::Min(200, $manifestContent.Length)))..."
            }
        } else {
            Write-Host "✗ manifest.json NOT FOUND in HytaleAssets!" -ForegroundColor Red
            Write-Host "  This is causing the asset loading failure." -ForegroundColor Red
        }

        Write-Host "`n  Files in HytaleAssets:" -ForegroundColor Cyan
        foreach ($file in $assetFiles | Select-Object -First 20) {
            $type = if ($file.is_file) { "FILE" } else { "DIR " }
            Write-Host "    [$type] $($file.name)"
        }
    }
} else {
    Write-Host "✗ HytaleAssets directory NOT FOUND!" -ForegroundColor Red
    Write-Host "  The server requires base game assets to run." -ForegroundColor Red
}
Write-Host ""

Write-Host "Step 3: Checking for world data..." -ForegroundColor Yellow
$worldDirs = @("worlds", "default", "world")
foreach ($worldDir in $worldDirs) {
    $world = $rootFiles | Where-Object { $_.name -eq $worldDir }
    if ($world) {
        Write-Host "✓ Found world directory: $worldDir" -ForegroundColor Yellow
        Write-Host "  This may be causing 'World already exists' error." -ForegroundColor Yellow
    }
}
Write-Host ""

Write-Host "=== Diagnosis Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. If HytaleAssets is missing or has no manifest.json, you need to reinstall server files"
Write-Host "2. If world directories exist and cause conflicts, you can delete them with:"
Write-Host "   Remove-ServerFile '/worlds'" -ForegroundColor Gray
Write-Host "3. Check the output above for specific issues"
Write-Host ""
Write-Host "Would you like me to:" -ForegroundColor Cyan
Write-Host "  A) Delete world data (if exists) to fix 'world already exists' error"
Write-Host "  B) Show full diagnostic output for manual review"
Write-Host "  C) Exit and let you handle manually"
