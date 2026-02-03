# HyTale Server Connection Troubleshooting

**Server:** deadeyeg4ming.vip:5520
**Status:** ✅ Network Working | ⚠️ Client Connection Issues

## What's Working

- ✅ Internet → OVH VPS (51.222.12.162) connectivity
- ✅ WireGuard tunnel (OVH VPS ↔ Home Network)
- ✅ Port forwarding (5520 → 10.0.10.46)
- ✅ HyTale server is running and responding
- ✅ Server is authenticated with Hytale Session Service
- ✅ UDP packets reaching server (5 packets, 6240 bytes received)

## Current Issue

**Error:** "FAILED TO CONNECT TO SERVER - The connection timed out from inactivity"

**What this means:** Client successfully contacted the server but the connection didn't complete, likely due to:
1. Version mismatch between client and server
2. Authentication/session issue
3. Network timeout during handshake

## Troubleshooting Steps

### 1. Verify Client Version ⚠️ MOST LIKELY ISSUE

**Server Version:** `HytaleServer v2026.01.13-dcad8778f (release)`
**Files Updated:** January 17, 2026

**Action Required:**
1. Have your son open Hytale launcher
2. Check client version (should show in launcher)
3. **Versions MUST match exactly**
4. If different, update client or server to match

### 2. Check Client Authentication

**Server is authenticated to:**
- `https://sessions.hytale.com`
- Found 1 game profile
- Session created successfully

**Client Requirements:**
- Must be logged into valid Hytale account
- Account must have access to current game version
- Check launcher shows "Logged in as [username]"

### 3. Monitor Connection Attempt

Run this to see real-time server logs:
```powershell
.\monitor-hytale-connection.ps1
```

Then have son try to connect. Look for:
- Connection attempt messages
- Version mismatch errors
- Authentication failures
- Any error messages

### 4. Test from Different Network

To isolate if it's a network latency issue:
- Try connecting from same local network (10.0.10.x)
  - Server address: `10.0.10.46:5520`
- If that works, issue is external connectivity/latency
- If that also fails, issue is server configuration or version

### 5. Check Server Console

The server has these auth commands:
```
/auth status       - Check current authentication
/auth select       - Switch game profile (if multiple)
/auth logout       - Log out (requires re-authentication)
```

Current status: **Already authenticated** ✅

### 6. Verify Port Forwarding Working

Check packet counts:
```bash
ssh 51.222.12.162 "sudo iptables -t nat -L PREROUTING -n -v | grep 5520"
```

**Current counts:**
- TCP: 1 packet (52 bytes)
- UDP: 5 packets (6240 bytes) ← This shows client IS reaching server

If these numbers increase when connecting, network path is fine.

### 7. Check for Server Errors

```bash
ssh 10.0.10.3 "pct exec 107 -- docker logs --since 10m 1887c9f7-1c15-447f-bf81-25d48a6dd13b | grep -i error"
```

## Common Fixes

### Fix 1: Update Client to Match Server

**If client is older than 2026.01.13:**
1. Update Hytale launcher
2. Download latest client version
3. Restart launcher
4. Try connecting again

### Fix 2: Update Server to Match Client

**If client is newer than 2026.01.13:**

Via Pterodactyl Panel:
1. Go to http://10.0.10.45
2. Log in
3. Find HyTale server
4. Look for "Reinstall" or "Update" option
5. Click and wait for completion

Via PowerShell script:
```powershell
.\wipe-hytale-server.ps1
```
**WARNING:** This may reset server data!

### Fix 3: Restart Server

Sometimes a fresh start helps:
```bash
ssh 10.0.10.3 "pct exec 107 -- docker restart 1887c9f7-1c15-447f-bf81-25d48a6dd13b"
```

Wait ~15 seconds for server to boot, then try connecting.

### Fix 4: Check Firewall on Client Side

Some antivirus/firewall software blocks game connections:
- Windows Firewall
- Antivirus software
- Router parental controls
- ISP restrictions

Try temporarily disabling client firewall to test.

## Network Diagnostics

### From Windows (your machine):
```powershell
# Test DNS
nslookup deadeyeg4ming.vip

# Test ping (should work)
ping deadeyeg4ming.vip

# Test TCP (will fail - expected, server is UDP only)
Test-NetConnection -ComputerName deadeyeg4ming.vip -Port 5520
```

### From Server:
```bash
# Check WireGuard tunnel
ssh 51.222.12.162 "ping -c 3 10.0.10.46"

# Check server status
ssh 10.0.10.3 "pct exec 107 -- docker ps | grep 1887c9f7"

# Check server listening ports
ssh 10.0.10.3 "pct exec 107 -- ss -ulnp | grep 5520"
```

## Technical Details

**Network Path:**
```
Client → Internet
  ↓
deadeyeg4ming.vip (DNS) → 51.222.12.162 (OVH VPS)
  ↓
WireGuard wg0 (10.0.9.1)
  ↓ tunnel
UCG Ultra WireGuard Client (10.0.9.2)
  ↓
Home Network (10.0.10.0/24)
  ↓
Pterodactyl Wings (10.0.10.46)
  ↓
Docker Container (172.18.0.2)
  ↓
HyTale Server (UDP port 5520)
```

**Latency:** ~26ms (OVH VPS → Home Network)

**Protocol:** UDP only (TCP tests will always fail)

## Next Steps

1. **Verify client version** (most important!)
2. Run monitor script during connection attempt
3. Check server logs for error messages
4. If version mismatch, update client or server
5. Test from local network if possible

## Files Available

- `monitor-hytale-connection.ps1` - Real-time log monitoring
- `wipe-hytale-server.ps1` - Server update script (destructive)
- `check-hytale-connectivity.sh` - Network connectivity test
- `fix-hytale-server.md` - Detailed network fix documentation

## Support

If none of these work:
1. Capture logs during connection attempt with monitor script
2. Check Hytale's official documentation for client/server requirements
3. Verify both client and server are on same game version/build
4. Check if Hytale Session Service is online (https://sessions.hytale.com)

## Last Known Good State

- **Server Version:** 2026.01.13-dcad8778f
- **Last Updated:** January 17, 2026
- **Authentication:** Working (Session Service connected)
- **Network:** Fully operational
- **Packets Received:** 5 UDP packets (6240 bytes) - proves connectivity works
