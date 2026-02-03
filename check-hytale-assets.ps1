# Check for HytaleAssets locally and provide upload instructions

Write-Host "=== Hytale Assets Installation Guide ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "The server is missing the HytaleAssets directory, which contains:" -ForegroundColor Yellow
Write-Host "  - manifest.json (required)"
Write-Host "  - All game data files"
Write-Host "  - Block definitions, entities, etc."
Write-Host ""

Write-Host "Options to fix this:" -ForegroundColor Cyan
Write-Host ""

Write-Host "Option 1: Check if you have HytaleAssets locally" -ForegroundColor Green
Write-Host "  - Look for HytaleAssets folder in your Hytale game installation"
Write-Host "  - Or in your Hytale server download package"
Write-Host "  - Location might be:"
Write-Host "    • Downloads folder where you got HytaleServer.jar"
Write-Host "    • Extracted Hytale server package directory"
Write-Host ""

Write-Host "Option 2: Re-download Hytale Server Package" -ForegroundColor Green
Write-Host "  - The HytaleServer.jar alone isn't enough"
Write-Host "  - You need the complete server package with assets"
Write-Host "  - Check Hytale's official server download or documentation"
Write-Host ""

Write-Host "Option 3: Extract from HytaleServer.jar (if assets are embedded)" -ForegroundColor Green
Write-Host "  - Some servers bundle assets inside the JAR"
Write-Host "  - The server might auto-extract on first run"
Write-Host "  - But logs show it's looking for external HytaleAssets/"
Write-Host ""

Write-Host "=== Quick Check ===" -ForegroundColor Yellow
Write-Host ""

# Check common locations
$searchPaths = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Desktop",
    "C:\Users\Fred\projects",
    "C:\Hytale",
    "C:\Games"
)

Write-Host "Searching for HytaleAssets on your local machine..." -ForegroundColor Cyan
$found = $false

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $assets = Get-ChildItem -Path $path -Recurse -Directory -Filter "HytaleAssets" -ErrorAction SilentlyContinue -Depth 3
        if ($assets) {
            Write-Host "✓ FOUND HytaleAssets at:" -ForegroundColor Green
            foreach ($asset in $assets) {
                Write-Host "  $($asset.FullName)" -ForegroundColor Green

                # Check for manifest.json
                $manifestPath = Join-Path $asset.FullName "manifest.json"
                if (Test-Path $manifestPath) {
                    Write-Host "    ✓ Contains manifest.json" -ForegroundColor Green
                } else {
                    Write-Host "    ✗ Missing manifest.json" -ForegroundColor Red
                }
            }
            $found = $true
        }
    }
}

if (-not $found) {
    Write-Host "✗ HytaleAssets not found in common locations" -ForegroundColor Red
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Locate your Hytale server download package"
    Write-Host "2. Extract it completely (not just HytaleServer.jar)"
    Write-Host "3. Upload the HytaleAssets folder to Pterodactyl"
    Write-Host ""
    Write-Host "To upload via Pterodactyl:" -ForegroundColor Cyan
    Write-Host "  a) Compress HytaleAssets into a .zip or .tar.gz"
    Write-Host "  b) Use Pterodactyl File Manager 'Upload' button"
    Write-Host "  c) Extract it in the server root directory"
    Write-Host ""
    Write-Host "OR use SCP/SFTP:" -ForegroundColor Cyan
    Write-Host "  sftp://10.0.10.45 (use Pterodactyl SFTP credentials)"
}

Write-Host ""
Write-Host "=== Current Server Files ===" -ForegroundColor Yellow

# Show what's currently on the server
$API_KEY = "ptlc_xEl0i8zwohLvizEC503CgkVRGPBNUnPKdMfIujIi0gj"
$PANEL_URL = "http://10.0.10.45"
$SERVER_ID = "415ef753-aa42-4c33-ae12-bbcc44d971f7"

$headers = @{
    "Authorization" = "Bearer $API_KEY"
    "Accept" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$PANEL_URL/api/client/servers/$SERVER_ID/files/list?directory=/" -Method GET -Headers $headers
    Write-Host "Files currently on server:" -ForegroundColor Cyan
    foreach ($file in $response.data) {
        $type = if ($file.is_file) { "FILE" } else { "DIR " }
        $size = if ($file.size -gt 1MB) { "$([math]::Round($file.size/1MB, 2)) MB" } else { "$($file.size) B" }
        Write-Host "  [$type] $($file.name) - $size"
    }
} catch {
    Write-Host "Could not retrieve server files" -ForegroundColor Red
}

Write-Host ""
Write-Host "Where did you get HytaleServer.jar from?" -ForegroundColor Yellow
Write-Host "That source should also have the HytaleAssets directory." -ForegroundColor Yellow
