#!/bin/bash

# === Load .env if it exists ===
# === Load .env if it exists ===
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    set -a
    . "$ENV_FILE"
    set +a
fi
# === Configuration ===
SOURCE_DIR="${SOURCE_DIR:-/path/to/your/dokuwiki}"
DEST_DIR="/tmp/dokuwiki-backup"
OWNER="${OWNER:-}"
MAX_BACKUPS=3

# === Ensure DEST_DIR Exists ===
if [ ! -d "$DEST_DIR" ]; then
    echo "Destination directory $DEST_DIR does not exist. Creating it..."
    mkdir -p "$DEST_DIR" || {
        echo "Failed to create destination directory. Exiting."
        exit 1
    }
fi

# === Generate Date and Output Path ===
DATE=$(date +%Y%m%d)
DEST_TAR="${DEST_DIR}/dokuwiki-${DATE}.tar.gz"

# === Create the Tarball ===
tar -czpf "$DEST_TAR" -C "$SOURCE_DIR" storage root

# === Chown the tarball if OWNER is valid ===
if [ -n "$OWNER" ]; then
    if id -u "${OWNER%%:*}" >/dev/null 2>&1; then
        chown "$OWNER" "$DEST_TAR"
    else
        echo "Warning: OWNER '$OWNER' is not a valid user. Skipping chown."
    fi
else
    echo "No OWNER specified. Skipping chown."
fi

echo "Backup created at: $DEST_TAR"

# === Prune old backups ===
echo "Pruning old backups (keeping latest $MAX_BACKUPS)..."
find "$DEST_DIR" -maxdepth 1 -type f -name 'dokuwiki-*.tar.gz' \
    | sort -r \
    | tail -n +$((MAX_BACKUPS + 1)) \
    | xargs -r rm -v
