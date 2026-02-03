# Monitor HyTale Server Connection Attempts
# Run this script, then have your son try to connect

Write-Host "Monitoring HyTale server logs for connection attempts..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Yellow
Write-Host ""

ssh 10.0.10.3 "pct exec 107 -- docker logs -f --tail 50 1887c9f7-1c15-447f-bf81-25d48a6dd13b 2>&1"
