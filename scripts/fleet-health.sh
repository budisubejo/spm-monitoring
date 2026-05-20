#!/bin/bash
# fleet-health.sh — Check health of all SPM Monitoring Pi fleet
# Usage: ./fleet-health.sh

PI_USER="admin"
PI_PASS="Kopi1Rokok24000"

# Known Pi fleet IPs
FLEET=(
  "192.168.60.41"
  "192.168.60.42"
  "192.168.60.43"
  "192.168.60.44"
  "192.168.60.45"
)

echo "=== SPM Fleet Health Check $(date) ==="
echo ""

for IP in "${FLEET[@]}"; do
  # Ping check
  ping -c1 -W2 $IP > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "❌ $IP — OFFLINE (no ping)"
    continue
  fi

  # SSH + service check
  STATUS=$(sshpass -p "$PI_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $PI_USER@$IP "
    HOSTNAME=\$(hostname)
    SPM=\$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://localhost:8000/api/health 2>/dev/null || echo 'N/A')
    NR=\$(systemctl is-active nodered 2>/dev/null || echo 'N/A')
    MEM=\$(free -h | awk '/Mem:/{print \$3\"/\"\$2}')
    DISK=\$(df -h / | awk 'NR==2{print \$5}')
    UPTIME=\$(uptime -p)
    echo \"\$HOSTNAME | SPM:\$SPM | NR:\$NR | Mem:\$MEM | Disk:\$DISK | \$UPTIME\"
  " 2>/dev/null)

  if [ -z "$STATUS" ]; then
    echo "⚠️  $IP — SSH failed"
  else
    echo "✅ $IP — $STATUS"
  fi
done

echo ""
echo "=== Done ==="
