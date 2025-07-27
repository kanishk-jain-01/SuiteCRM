<?php
/**
 * Simple Health Check Endpoint for SuiteCRM
 * This endpoint provides basic health status even during installation
 */

// Set headers
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');

// Basic health check data
$health = [
    'status' => 'ok',
    'timestamp' => date('c'),
    'service' => 'suitecrm',
    'checks' => []
];

// Check if Apache is running (we're here, so it is)
$health['checks']['webserver'] = [
    'status' => 'healthy',
    'message' => 'Apache is running'
];

// Check database connectivity
try {
    if (getenv('DB_HOST') && getenv('DB_USER') && getenv('DB_PASSWORD')) {
        $db = new PDO(
            'mysql:host=' . getenv('DB_HOST') . ';port=3306', 
            getenv('DB_USER'), 
            getenv('DB_PASSWORD'),
            [PDO::ATTR_TIMEOUT => 5]
        );
        $health['checks']['database'] = [
            'status' => 'healthy',
            'message' => 'Database connection successful'
        ];
    } else {
        $health['checks']['database'] = [
            'status' => 'warning',
            'message' => 'Database environment variables not set'
        ];
    }
} catch (Exception $e) {
    $health['checks']['database'] = [
        'status' => 'unhealthy',
        'message' => 'Database connection failed: ' . $e->getMessage()
    ];
}

// Check if SuiteCRM is installed
if (file_exists('/var/www/html/config.php')) {
    $health['checks']['suitecrm'] = [
        'status' => 'healthy',
        'message' => 'SuiteCRM config.php exists'
    ];
} else {
    $health['checks']['suitecrm'] = [
        'status' => 'installing',
        'message' => 'SuiteCRM installation in progress'
    ];
}

// Check file permissions
$upload_dir = '/var/www/html/upload';
if (is_writable($upload_dir)) {
    $health['checks']['permissions'] = [
        'status' => 'healthy',
        'message' => 'File permissions OK'
    ];
} else {
    $health['checks']['permissions'] = [
        'status' => 'warning',
        'message' => 'Upload directory not writable'
    ];
}

// Determine overall status
$overall_status = 'healthy';
foreach ($health['checks'] as $check) {
    if ($check['status'] === 'unhealthy') {
        $overall_status = 'unhealthy';
        break;
    } elseif ($check['status'] === 'warning' || $check['status'] === 'installing') {
        $overall_status = 'warning';
    }
}

$health['status'] = $overall_status;

// Set appropriate HTTP status code
http_response_code($overall_status === 'unhealthy' ? 503 : 200);

// Output JSON
echo json_encode($health, JSON_PRETTY_PRINT);
?> 