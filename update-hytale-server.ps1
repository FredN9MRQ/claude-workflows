# Update HyTale Server to Latest Version
# Current: 2026.01.13 → Target: 2026.01.24+

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  HyTale Server Update to 2026.01.24" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Current Server: v2026.01.13-dcad8778f" -ForegroundColor Yellow
Write-Host "Client Version:  2026.01.24-997c2cb" -ForegroundColor Green
Write-Host ""
Write-Host "This will:" -ForegroundColor White
Write-Host "  1. Stop the HyTale container"
Write-Host "  2. Pull latest hytale-java25 Docker image"
Write-Host "  3. Restart container"
Write-Host ""
Write-Host "Note: World data should be preserved (in /universe folder)" -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "Continue with update? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Update cancelled" -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "[1/4] Checking current server status..." -ForegroundColor Cyan
ssh 10.0.10.3 "pct exec 107 -- docker ps --filter id=1887c9f7 --format 'Status: {{.Status}}'"

Write-Host ""
Write-Host "[2/4] Stopping HyTale server..." -ForegroundColor Cyan
ssh 10.0.10.3 "pct exec 107 -- docker stop 1887c9f7-1c15-447f-bf81-25d48a6dd13b"
Write-Host "  ✓ Server stopped" -ForegroundColor Green

Write-Host ""
Write-Host "[3/4] Pulling latest HyTale image (this may take a few minutes)..." -ForegroundColor Cyan
ssh 10.0.10.3 "pct exec 107 -- docker pull hytale-java25:latest"

Write-Host ""
Write-Host "[4/4] Starting HyTale server with new version..." -ForegroundColor Cyan
ssh 10.0.10.3 "pct exec 107 -- docker start 1887c9f7-1c15-447f-bf81-25d48a6dd13b"
Write-Host "  ✓ Server started" -ForegroundColor Green

Write-Host ""
Write-Host "Waiting 15 seconds for server to boot..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host ""
Write-Host "Checking server status..." -ForegroundColor Cyan
ssh 10.0.10.3 "pct exec 107 -- docker logs --tail 5 1887c9f7-1c15-447f-bf81-25d48a6dd13b 2>&1 | grep -i 'boot\|version\|ready'"

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "  Update Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Wait ~30 seconds for full startup"
Write-Host "  2. Run monitor script: .\monitor-hytale-connection.ps1"
Write-Host "  3. Have your son try connecting to: deadeyeg4ming.vip:5520"
Write-Host ""
Write-Host "Check server version with:" -ForegroundColor White
Write-Host '  ssh 10.0.10.3 "pct exec 107 -- docker exec 1887c9f7 java -jar HytaleServer.jar --version"' -ForegroundColor Gray
