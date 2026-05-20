#!/bin/bash
# fix-sqlite.sh — Repair SQLite database corruption
# Usage: ./fix-sqlite.sh [path-to-database.sqlite]

DB="${1:-/home/admin/spm-project/spm-monitoring/database/database.sqlite}"

echo "=== SQLite Repair: $DB ==="

# Backup first
BACKUP="${DB}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$DB" "$BACKUP"
echo "Backup: $BACKUP"

# Try VACUUM first (fixes freelist corruption)
echo "Running VACUUM..."
sqlite3 "$DB" "VACUUM;"

# Check integrity
RESULT=$(sqlite3 "$DB" "PRAGMA integrity_check;")
echo "Integrity: $RESULT"

if [ "$RESULT" = "ok" ]; then
  echo "✅ Database OK"
  rm "$BACKUP"
else
  echo "⚠️  Still corrupt, trying REINDEX..."
  sqlite3 "$DB" "REINDEX device_readings;"
  RESULT2=$(sqlite3 "$DB" "PRAGMA integrity_check;")
  echo "Integrity after REINDEX: $RESULT2"

  if [ "$RESULT2" = "ok" ]; then
    echo "✅ Fixed with REINDEX"
    rm "$BACKUP"
  else
    echo "❌ Still corrupt. Backup kept at: $BACKUP"
    echo "Manual recovery needed."
  fi
fi
