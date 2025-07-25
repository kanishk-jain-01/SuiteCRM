#!/bin/bash

# SuiteCRM startup script for Docker
set -e

echo "Starting SuiteCRM container..."

PERSIST_CONFIG="/var/www/html/config-persistence/config.php"
CONFIG_FILE="/var/www/html/config.php"

# Ensure the persistence directory exists
mkdir -p /var/www/html/config-persistence
chown www-data:www-data /var/www/html/config-persistence

# Check if config.php exists in persistent storage
if [ -f "$PERSIST_CONFIG" ]; then
    echo "Found existing config.php in persistent storage, creating symlink"
    ln -sf "$PERSIST_CONFIG" "$CONFIG_FILE"
    chown -h www-data:www-data "$CONFIG_FILE"
else
    echo "No existing config.php found, will monitor for creation during installation"
    # Background process to monitor for config.php creation and persist it
    (
        while [ ! -f "$CONFIG_FILE" ]; do
            sleep 2
        done
        echo "Config file created, saving to persistent storage..."
        cp "$CONFIG_FILE" "$PERSIST_CONFIG"
        chown www-data:www-data "$PERSIST_CONFIG"
        # Replace the original with a symlink to the persistent version
        rm "$CONFIG_FILE"
        ln -sf "$PERSIST_CONFIG" "$CONFIG_FILE"
        chown -h www-data:www-data "$CONFIG_FILE"
        echo "Config.php successfully saved to persistent storage and symlinked"
    ) &
fi

# Remove the old save-config.php hook as we're handling persistence directly
if [ -f "/var/www/html/save-config.php" ]; then
    rm -f /var/www/html/save-config.php
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start Apache
echo "Starting Apache web server..."
exec apache2-foreground