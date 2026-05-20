#!/bin/bash
# fix-permissions.sh — Fix Laravel storage permissions on Pi
# Run this if you get "Permission denied" errors on storage/cache

DEPLOY_PATH="${1:-/home/admin/spm-project/spm-monitoring}"

echo "Fixing permissions for: $DEPLOY_PATH"

sudo chown -R admin:admin "$DEPLOY_PATH/storage/"
sudo chmod -R 777 "$DEPLOY_PATH/storage/"
sudo chmod -R 777 "$DEPLOY_PATH/bootstrap/cache/"
chmod 666 "$DEPLOY_PATH/database/database.sqlite"

cd "$DEPLOY_PATH"
php artisan cache:clear
php artisan config:clear

# Restart PHP-FPM if running
sudo systemctl restart php8.2-fpm 2>/dev/null || true

echo "Done! Permissions fixed."
