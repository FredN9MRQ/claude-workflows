# HyTale Server Update Script
# WARNING: This will wipe the server and download fresh files

Write-Host "HyTale Server Update Script" -ForegroundColor Cyan
Write-Host "Current version: 2026.01.13 (Jan 17 update)"
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "1. Stop the HyTale container"
Write-Host "2. Back up world data (if exists)"
Write-Host "3. Pull latest hytale-java25:latest image"
Write-Host "4. Restart container with new image"
Write-Host ""
Write-Host "WARNING: Server will be down during update!" -ForegroundColor Red
Write-Host ""
$confirm = Read-Host "Continue? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Update cancelled" -ForegroundColor Yellow
    exit
}

# Stop container
Write-Host "Stopping HyTale server..." -ForegroundColor Cyan
ssh 10.0.10.3 "pct exec 107 -- docker stop 1887c9f7-1c15-447f-bf81-25d48a6dd13b"

# Pull latest image
Write-Host "Pulling latest hytale-java25 image..." -ForegroundColor Cyan
ssh 10.0.10.3 "pct exec 107 -- docker pull hytale-java25:latest"

# Start container
Write-Host "Starting HyTale server..." -ForegroundColor Cyan
ssh 10.0.10.3 "pct exec 107 -- docker start 1887c9f7-1c15-447f-bf81-25d48a6dd13b"

Write-Host ""
Write-Host "Update complete! Monitor logs with:" -ForegroundColor Green
Write-Host "ssh 10.0.10.3 'pct exec 107 -- docker logs -f 1887c9f7-1c15-447f-bf81-25d48a6dd13b'" -ForegroundColor White
