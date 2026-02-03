# Update HyTale Server via Pterodactyl Panel

**Current Server:** v2026.01.13 (Jan 17 files)
**Client Version:** v2026.01.24
**Downloaded Update:** ✅ 2026.01.24-6e2d4fc36.zip (already on server!)

## ⚠️ IMPORTANT: Use Pterodactyl Panel, Not Docker Pull

The server is managed by Pterodactyl Wings, which downloads updates from the panel at http://10.0.10.45.

**Do NOT use the `update-hytale-server.ps1` script** - it won't work because:
- Pterodactyl doesn't update via Docker image pulls
- Updates come from the panel's remote API
- Server files are in `/var/lib/pterodactyl/volumes/`

## Method 1: Pterodactyl Web Panel (Recommended)

1. **Access the panel:**
   - URL: http://10.0.10.45
   - Or via public domain if configured

2. **Find your HyTale server:**
   - Look for server with container ID: `1887c9f7-1c15-447f-bf81-25d48a6dd13b`
   - Or search for "HyTale" or server name

3. **Reinstall/Update:**
   - Navigate to server settings
   - Look for "Reinstall Server" or "Update" button
   - This will extract the already-downloaded `2026.01.24-6e2d4fc36.zip`
   - **Warning:** May reset server config - backup first!

4. **Or use Startup tab:**
   - Some Pterodactyl eggs have update commands
   - Check for update buttons or commands

## Method 2: Manual Update (Advanced)

Since the update is already downloaded, you can manually extract it:

```bash
# Connect to Wings container
ssh 10.0.10.3 "pct exec 107 -- bash"

# Navigate to server directory
cd /var/lib/pterodactyl/volumes/1887c9f7-1c15-447f-bf81-25d48a6dd13b/

# Stop server first (via Pterodactyl panel or)
docker stop 1887c9f7-1c15-447f-bf81-25d48a6dd13b

# Backup current files
mkdir -p ~/backup-hytale-$(date +%Y%m%d)
cp HytaleServer.jar HytaleServer.aot config.json ~/backup-hytale-$(date +%Y%m%d)/

# Extract new version
unzip -o 2026.01.24-6e2d4fc36.zip

# Start server (via panel or)
docker start 1887c9f7-1c15-447f-bf81-25d48a6dd13b
```

## Method 3: Use hytale-downloader Tool

The server has a downloader tool already:

```bash
ssh 10.0.10.3 "pct exec 107 -- bash -c 'cd /var/lib/pterodactyl/volumes/1887c9f7-1c15-447f-bf81-25d48a6dd13b/ && ./hytale-downloader-linux-amd64 --help'"
```

This might have update capabilities built-in.

## Verify Update After Installation

```powershell
# Check server version
ssh 10.0.10.3 "pct exec 107 -- docker exec 1887c9f7-1c15-447f-bf81-25d48a6dd13b java -jar HytaleServer.jar --version"

# Should show: HytaleServer v2026.01.24-6e2d4fc36 (or similar)
```

## Files Currently on Server

```
✅ 2026.01.24-6e2d4fc36.zip (1.4GB) - NEW VERSION READY
❌ HytaleServer.jar (83MB, Jan 17) - OLD VERSION
❌ HytaleServer.aot (122MB, Jan 17) - OLD VERSION
✅ Assets.zip (3.5GB, Jan 17) - May need update too
✅ config.json - User settings
✅ universe/ - World data (preserve!)
✅ mods/ - Installed mods
```

## Recommended Steps

1. **Access Pterodactyl panel** at http://10.0.10.45
2. **Stop the server** (via panel)
3. **Backup world data:**
   ```bash
   ssh 10.0.10.3 "pct exec 107 -- tar czf ~/hytale-backup-$(date +%Y%m%d).tar.gz /var/lib/pterodactyl/volumes/1887c9f7-1c15-447f-bf81-25d48a6dd13b/universe/"
   ```
4. **Use panel's reinstall/update feature** (this will use the downloaded zip)
5. **Start server**
6. **Verify version matches client** (2026.01.24)

## If Panel Method Doesn't Work

Let me know and I can create a manual extraction script that:
- Stops server safely
- Backs up current files
- Extracts the new version from the zip
- Preserves world data and config
- Starts server with new version

## Important Notes

- ✅ Update is already downloaded (1.4GB zip file)
- ✅ World data in `universe/` should be preserved
- ⚠️ Config might reset - backup first
- ⚠️ Authentication credentials in `.hytale-downloader-credentials.json` should be preserved
