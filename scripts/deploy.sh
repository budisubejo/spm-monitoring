#!/bin/bash
# deploy.sh — Deploy SPM Monitoring to a Raspberry Pi
# Usage: ./deploy.sh <pi-ip>

PI_IP=${1:-"192.168.60.42"}
PI_USER="admin"
PI_PASS="Kopi1Rokok24000"
DEPLOY_PATH="/home/admin/spm-project/spm-monitoring"

echo "=== SPM Monitoring Deploy to $PI_IP ==="

# 1. Create project archive (exclude heavy dirs)
echo "[1/5] Creating archive..."
tar czf /tmp/spm-deploy.tar.gz \
  --exclude='vendor' \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='storage/logs/*.log' \
  -C /home/admin/spm-project spm-monitoring

# 2. Copy to Pi
echo "[2/5] Copying to Pi..."
sshpass -p "$PI_PASS" scp -o StrictHostKeyChecking=no \
  /tmp/spm-deploy.tar.gz $PI_USER@$PI_IP:/tmp/

# 3. Extract and install
echo "[3/5] Extracting..."
sshpass -p "$PI_PASS" ssh -o StrictHostKeyChecking=no $PI_USER@$PI_IP "
  mkdir -p /home/admin/spm-project
  tar xzf /tmp/spm-deploy.tar.gz -C /home/admin/spm-project/
  cd $DEPLOY_PATH
  composer install --no-dev --quiet 2>/dev/null || true
"

# 4. Fix permissions
echo "[4/5] Fixing permissions..."
sshpass -p "$PI_PASS" ssh -o StrictHostKeyChecking=no $PI_USER@$PI_IP "
  chmod -R 777 $DEPLOY_PATH/storage/
  chmod -R 777 $DEPLOY_PATH/bootstrap/cache/
  touch $DEPLOY_PATH/database/database.sqlite
  chmod 666 $DEPLOY_PATH/database/database.sqlite
  chown -R admin:admin $DEPLOY_PATH/
"

# 5. Start service
echo "[5/5] Starting SPM Monitoring..."
sshpass -p "$PI_PASS" ssh -o StrictHostKeyChecking=no $PI_USER@$PI_IP "
  cd $DEPLOY_PATH
  php artisan migrate --force 2>/dev/null || true
  sudo systemctl restart spm-monitoring 2>/dev/null || \
    nohup php artisan serve --host=0.0.0.0 --port=8000 &>/tmp/spm.log &
  echo 'Done! Access at http://$PI_IP:8000'
"

echo "=== Deploy complete ==="
