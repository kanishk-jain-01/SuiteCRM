#!/bin/bash

# SuiteCRM startup script for Docker
set -e

echo "Starting SuiteCRM container..."

# Check if config.php exists in persistent storage
if [ -f "/var/www/html/config-persistence/config.php" ]; then
    echo "Found existing config.php, copying to application directory"
    cp /var/www/html/config-persistence/config.php /var/www/html/config.php
    chown www-data:www-data /var/www/html/config.php
else
    echo "No existing config.php found, installer will run on first access"
    # Ensure the persistence directory exists
    mkdir -p /var/www/html/config-persistence
    chown www-data:www-data /var/www/html/config-persistence
fi

# Create a hook to save config.php when it's created
cat > /var/www/html/save-config.php << 'EOF'
<?php
// Hook to save config.php to persistent storage after installation
if (file_exists('/var/www/html/config.php') && !file_exists('/var/www/html/config-persistence/config.php')) {
    copy('/var/www/html/config.php', '/var/www/html/config-persistence/config.php');
    echo "Config saved to persistent storage\n";
}
EOF

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start Apache
echo "Starting Apache web server..."
exec apache2-foreground