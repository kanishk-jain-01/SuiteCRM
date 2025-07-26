#!/bin/bash

# SuiteCRM startup script for Docker
set -e

echo "Starting SuiteCRM container..."

# Configuration paths
PERSIST_CONFIG="/var/www/html/config-persistence/config.php"
CONFIG_FILE="/var/www/html/config.php"
CONFIG_SI_FILE="/var/www/html/config_si.php"

# Ensure the persistence directory exists
mkdir -p /var/www/html/config-persistence
chown www-data:www-data /var/www/html/config-persistence

# Function to validate required environment variables
validate_environment() {
    local required_vars=(
        "DB_HOST"
        "DB_NAME"
        "DB_USER"
        "DB_PASSWORD"
        "SITE_URL"
        "SYSTEM_NAME"
        "ADMIN_USERNAME"
        "ADMIN_PASSWORD"
    )
    
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "ERROR: Missing required environment variables:"
        printf '%s\n' "${missing_vars[@]}"
        echo ""
        echo "Please ensure all required variables are set in your deployment configuration."
        exit 1
    fi
    
    # Set defaults for optional variables
    export DB_CHARSET="${DB_CHARSET:-utf8mb4}"
    export DB_COLLATION="${DB_COLLATION:-utf8mb4_general_ci}"
    
    echo "Environment validation successful"
}

# Function to wait for database
wait_for_database() {
    echo "Waiting for database connection..."
    while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
        echo "Database not ready, waiting..."
        sleep 2
    done
    echo "Database connection established"
}

# Function to create database if it doesn't exist or recreate if empty
create_database() {
    echo "Checking if database exists..."
    if ! mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME;" 2>/dev/null; then
        echo "Creating database $DB_NAME..."
        mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET $DB_CHARSET COLLATE $DB_COLLATION;"
        echo "Database created successfully"
    else
        echo "Database $DB_NAME already exists"
        
        # Check if database has tables (proper schema)
        TABLE_COUNT=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -D"$DB_NAME" -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';" 2>/dev/null || echo "0")
        
        if [ "$TABLE_COUNT" -eq "0" ]; then
            echo "Database exists but has no tables. Recreating database..."
            mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE $DB_NAME;"
            mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE $DB_NAME CHARACTER SET $DB_CHARSET COLLATE $DB_COLLATION;"
            echo "Database recreated successfully"
        else
            echo "Database has $TABLE_COUNT tables - schema appears complete"
        fi
    fi
}

# Function to generate config_si.php for silent installation
generate_silent_install_config() {
    echo "Generating silent install configuration..."
    
    # Extract hostname from SITE_URL (remove http:// or https://)
    HOSTNAME_ONLY=$(echo "$SITE_URL" | sed 's|https\?://||')
    
    echo "DEBUG: SITE_URL = $SITE_URL"
    echo "DEBUG: HOSTNAME_ONLY = $HOSTNAME_ONLY"
    echo "DEBUG: ADMIN_USERNAME = $ADMIN_USERNAME"
    echo "DEBUG: ADMIN_PASSWORD is set = $([ -n "$ADMIN_PASSWORD" ] && echo "YES" || echo "NO")"
    
    cat > "$CONFIG_SI_FILE" << EOF
<?php
// SuiteCRM Silent Install Configuration
// This file is used for automated installation without web interface

\$sugar_config_si = array(
    // Database Configuration
    'setup_db_type' => 'mysql',
    'setup_db_host_name' => '$DB_HOST',
    'setup_db_port_num' => '3306',
    'setup_db_database_name' => '$DB_NAME',
    'setup_db_admin_user_name' => '$DB_USER',
    'setup_db_admin_password' => '$DB_PASSWORD',
    'setup_db_charset' => '$DB_CHARSET',
    'setup_db_collation' => '$DB_COLLATION',
    'setup_db_drop_tables' => false,
    'setup_db_create_database' => false,  // We handle this in startup.sh
    'setup_db_pop_demo_data' => false,
    
    // Site Configuration
    'setup_site_url' => '$SITE_URL',
    'setup_host_name' => '$HOSTNAME_ONLY',
    'setup_site_host_name' => '$HOSTNAME_ONLY',
    'setup_system_name' => '$SYSTEM_NAME',
    
    // Admin User Configuration
    'setup_site_admin_user_name' => '$ADMIN_USERNAME',
    'setup_site_admin_password' => '$ADMIN_PASSWORD',
    'setup_site_admin_password_retype' => '$ADMIN_PASSWORD',
    
    // License Agreement
    'setup_license_accept' => true,
    
    // System Configuration
    'default_currency_iso4217' => 'USD',
    'default_currency_name' => 'US Dollar',
    'default_currency_symbol' => '$',
    'default_currency_significant_digits' => '2',
    'default_date_format' => 'Y-m-d',
    'default_time_format' => 'H:i',
    'default_decimal_seperator' => '.',
    'default_export_charset' => 'UTF-8',
    'default_language' => 'en_us',
    'default_locale_name_format' => 's f l',
    'default_number_grouping_seperator' => ',',
    'export_delimiter' => ',',
    
    // Installation mode
    'setup_mode' => 'New_Installation',
);
EOF
    
    chown www-data:www-data "$CONFIG_SI_FILE"
    echo "Silent install configuration generated"
    echo "Config file contents:"
    cat "$CONFIG_SI_FILE"
}

# Function to run SuiteCRM silent installation using the correct CLI method
run_silent_installation() {
    echo "Running SuiteCRM silent installation..."
    
    # Validate environment variables first
    validate_environment
    
    # Wait for database and create if needed
    wait_for_database
    create_database
    
    # Generate silent install config
    generate_silent_install_config
    
    # Run the silent installer using PHP include method
    cd /var/www/html
    
    echo "Starting SuiteCRM CLI installation..."
    
    # Create a PHP script to run the installation
    cat > /tmp/silent_install.php << 'EOF'
<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

if (!defined('sugarEntry')) {
    define('sugarEntry', true);
}

// Include the config_si.php file first to make it available globally
if (file_exists('config_si.php')) {
    echo "Loading config_si.php...\n";
    include_once 'config_si.php';
    if (isset($sugar_config_si)) {
        echo "Configuration loaded successfully\n";
        
        // Debug: Print key configuration values
        echo "DEBUG: Site URL = " . (isset($sugar_config_si['setup_site_url']) ? $sugar_config_si['setup_site_url'] : 'NOT SET') . "\n";
        echo "DEBUG: Host Name = " . (isset($sugar_config_si['setup_host_name']) ? $sugar_config_si['setup_host_name'] : 'NOT SET') . "\n";
        echo "DEBUG: Site Host Name = " . (isset($sugar_config_si['setup_site_host_name']) ? $sugar_config_si['setup_site_host_name'] : 'NOT SET') . "\n";
        echo "DEBUG: Admin Username = " . (isset($sugar_config_si['setup_site_admin_user_name']) ? $sugar_config_si['setup_site_admin_user_name'] : 'NOT SET') . "\n";
        echo "DEBUG: Admin Password Set = " . (isset($sugar_config_si['setup_site_admin_password']) && !empty($sugar_config_si['setup_site_admin_password']) ? 'YES' : 'NO') . "\n";
        
        // Make config available globally BEFORE any other includes
        $GLOBALS['sugar_config_si'] = $sugar_config_si;
        
    } else {
        echo "ERROR: Failed to load configuration\n";
        exit(1);
    }
} else {
    echo "ERROR: config_si.php not found\n";
    exit(1);
}

// Set up the server and request variables for CLI mode
$_SERVER['HTTP_HOST'] = isset($sugar_config_si['setup_host_name']) ? $sugar_config_si['setup_host_name'] : 'localhost';
$_SERVER['REQUEST_URI'] = 'install.php';
$_SERVER['SERVER_SOFTWARE'] = 'Apache';
$_SERVER['SERVER_NAME'] = isset($sugar_config_si['setup_host_name']) ? $sugar_config_si['setup_host_name'] : 'localhost';
$_SERVER['SERVER_PORT'] = '80';
$_REQUEST['goto'] = 'SilentInstall';
$_REQUEST['cli'] = true;
$_POST['email_reminder_checked'] = false;

// Set up session variables that the installer expects
session_start();
foreach ($sugar_config_si as $key => $value) {
    $_SESSION[$key] = $value;
}

echo "DEBUG: Session variables set\n";
echo "DEBUG: SESSION site_url = " . (isset($_SESSION['setup_site_url']) ? $_SESSION['setup_site_url'] : 'NOT SET') . "\n";

// Run the installer
echo "Starting installation process...\n";
try {
    ob_start();
    
    // Include install functions that the installer needs
    if (file_exists('install/install_utils.php')) {
        include_once 'install/install_utils.php';
        echo "DEBUG: install_utils.php included\n";
        
        // Check what functions are available
        $install_functions = get_defined_functions()['user'];
        $silent_install_functions = array_filter($install_functions, function($func) {
            return stripos($func, 'silent') !== false || stripos($func, 'install') !== false;
        });
        echo "DEBUG: Available install-related functions: " . implode(', ', array_slice($silent_install_functions, 0, 10)) . "\n";
    }
    
    // Debug: Check if global variable is accessible
    echo "DEBUG: Checking global sugar_config_si availability...\n";
    if (isset($GLOBALS['sugar_config_si'])) {
        echo "DEBUG: GLOBALS sugar_config_si is SET\n";
        echo "DEBUG: GLOBALS site_url = " . (isset($GLOBALS['sugar_config_si']['setup_site_url']) ? $GLOBALS['sugar_config_si']['setup_site_url'] : 'NOT SET') . "\n";
    } else {
        echo "DEBUG: GLOBALS sugar_config_si is NOT SET\n";
    }
    
    // Debug: Test hostname validation logic by examining SuiteCRM's validation
    if (function_exists('checkSiteUrl') || function_exists('validateSiteUrl')) {
        echo "DEBUG: Found SuiteCRM URL validation function\n";
    }
    
    // Let's manually check what SuiteCRM is looking for in hostname validation
    if (file_exists('install/install_checks.php')) {
        include_once 'install/install_checks.php';
        echo "DEBUG: install_checks.php included\n";
    }
    
    // Try to find and call the exact function that's failing
    echo "DEBUG: Testing hostname validation manually...\n";
    $test_configs = [
        'setup_site_url' => $sugar_config_si['setup_site_url'],
        'setup_host_name' => $sugar_config_si['setup_host_name'],
        'setup_site_host_name' => $sugar_config_si['setup_site_host_name']
    ];
    
    foreach ($test_configs as $key => $value) {
        echo "DEBUG: Testing $key = '$value' (empty: " . (empty($value) ? 'YES' : 'NO') . ", isset: " . (isset($value) ? 'YES' : 'NO') . ")\n";
    }
    
    // Try to manually trigger the silent installation process
    if (function_exists('runSilentInstall')) {
        echo "DEBUG: Running runSilentInstall function\n";
        $result = runSilentInstall($sugar_config_si);
        echo "DEBUG: Silent install result: " . var_export($result, true) . "\n";
    } else {
        echo "DEBUG: runSilentInstall function not found, using install.php\n";
        
        // Set current step to trigger silent install
        $_REQUEST['current_step'] = '10'; // Silent install step
        $_POST['current_step'] = '10';
        
        echo "DEBUG: Set current_step to 10 for silent installation\n";
        
        // Add a custom error handler to catch exactly where the hostname error comes from
        set_error_handler(function($severity, $message, $file, $line) {
            if (stripos($message, 'host') !== false || stripos($message, 'blank') !== false) {
                echo "DEBUG: Hostname error caught at $file:$line - $message\n";
                debug_print_backtrace();
            }
            return false; // Let PHP handle the error normally
        });
        
        require_once 'install.php';
    }
    
    $output = ob_get_clean();
    
    // Check if installation was successful by looking for config.php
    if (file_exists('config.php')) {
        echo "SuiteCRM installation completed successfully\n";
        exit(0);
    } else {
        echo "ERROR: Installation failed - config.php was not created\n";
        if (!empty($output)) {
            echo "Installer output: " . $output . "\n";
        }
        
        // Additional debugging - check what files were created
        echo "DEBUG: Files in current directory:\n";
        $files = glob('*');
        foreach ($files as $file) {
            if (strpos($file, 'config') !== false || strpos($file, 'install') !== false) {
                echo "  - $file\n";
            }
        }
        
        exit(1);
    }
} catch (Exception $e) {
    echo "INSTALLATION FAILED! file: " . $e->getFile() . " - line: " . $e->getLine() . "\n";
    echo $e->getMessage() . "\n";
    echo "Stack trace:\n";
    echo $e->getTraceAsString() . "\n";
    exit(1);
}
EOF

    # Run the installation script
    php /tmp/silent_install.php
    
    INSTALL_EXIT=$?
    if [ $INSTALL_EXIT -eq 0 ]; then
        echo "SuiteCRM installation completed successfully"
        
        # Move config.php to persistent storage
        if [ -f "$CONFIG_FILE" ]; then
            mv "$CONFIG_FILE" "$PERSIST_CONFIG"
            ln -sf "$PERSIST_CONFIG" "$CONFIG_FILE"
            chown -h www-data:www-data "$CONFIG_FILE"
            echo "Configuration saved to persistent storage"
        else
            echo "WARNING: config.php was not created by the installer"
        fi
        
        # Clean up sensitive files
        rm -f "$CONFIG_SI_FILE"
        rm -f /tmp/silent_install.php
        echo "Cleaned up installation files"
    else
        echo "SuiteCRM installation failed with exit code $INSTALL_EXIT"
        exit $INSTALL_EXIT
    fi
}

# Main execution
if [ -f "$PERSIST_CONFIG" ]; then
    echo "Found existing config.php in persistent storage, creating symlink"
    ln -sf "$PERSIST_CONFIG" "$CONFIG_FILE"
    chown -h www-data:www-data "$CONFIG_FILE"
else
    echo "No existing config.php found, running silent installation"
    run_silent_installation
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start Apache
echo "Starting Apache web server..."
exec apache2-foreground