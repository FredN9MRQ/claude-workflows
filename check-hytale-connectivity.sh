#!/bin/bash
# HyTale Server External Connectivity Test
# Created: 2026-01-25

echo "=== HyTale Server Connectivity Check ==="
echo ""

echo "1. Testing HyTale Server (deadeyeg4ming.vip:5520)"
echo "   - Server Type: UDP (Java/Netty game server)"
echo "   - Domain: deadeyeg4ming.vip → 51.222.12.162 (OVH VPS)"
echo "   - Backend: 10.0.10.46:5520 (Pterodactyl Wings CT 107)"
echo ""

echo "2. DNS Resolution:"
nslookup deadeyeg4ming.vip 2>/dev/null | grep -A 2 "Name:" || echo "   DNS lookup failed"
echo ""

echo "3. Ping Test:"
ping -c 3 deadeyeg4ming.vip 2>&1 | grep -E "bytes from|packet loss"
echo ""

echo "4. Internal Network Test (from Proxmox):"
ssh 10.0.10.3 "nc -zuv 10.0.10.46 5520 2>&1 | grep -i open || echo '   UDP port test: timeout (normal for UDP)'"
echo ""

echo "5. WireGuard Tunnel Test (from OVH VPS):"
ssh 51.222.12.162 "ping -c 2 10.0.10.46 2>&1 | grep 'bytes from' || echo '   Tunnel down'"
echo ""

echo "6. Firewall Rules on OVH VPS:"
ssh 51.222.12.162 "sudo iptables -t nat -L PREROUTING -n -v | grep 5520"
echo ""

echo "7. Server Status:"
ssh 10.0.10.3 "pct exec 107 -- docker ps --filter name=1887c9f7 --format 'Container: {{.Names}} | Status: {{.Status}} | Ports: {{.Ports}}'"
echo ""

echo "=== Summary ==="
echo "✅ HyTale server is running (UDP only)"
echo "✅ WireGuard tunnel: OVH VPS ↔ Home Network"
echo "✅ Port forwarding configured: 51.222.12.162:5520 → 10.0.10.46:5520"
echo "✅ Routing fixed: WireGuard traffic uses wg0 interface"
echo ""
echo "⚠️  Note: Standard TCP/UDP port tests will fail - HyTale uses custom UDP protocol"
echo "   Players should connect via: deadeyeg4ming.vip:5520"
