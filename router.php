<?php
/**
 * Router script for PHP built-in server to handle SuiteCRM API routing
 * This simulates Apache's .htaccess rewrite rules for the API
 */

$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

// Handle API routes
if (strpos($uri, '/Api/') === 0) {
    // Remove /Api/ prefix and set up environment for API routing
    $apiPath = substr($uri, 5); // Remove '/Api/' prefix
    
    // Set up proper environment variables for the API
    $_SERVER['REQUEST_URI'] = '/' . $apiPath;
    $_SERVER['SCRIPT_NAME'] = '/Api/index.php';
    $_SERVER['PHP_SELF'] = '/Api/index.php';
    
    // Change to the Api directory and include the API entry point
    chdir(__DIR__ . '/Api');
    include 'index.php';
    return;
}

// Handle static files
if (file_exists(__DIR__ . $uri)) {
    return false; // Let the server handle static files
}

// For all other requests, serve the main SuiteCRM application
if (file_exists(__DIR__ . '/index.php')) {
    include __DIR__ . '/index.php';
} else {
    http_response_code(404);
    echo "File not found";
} 