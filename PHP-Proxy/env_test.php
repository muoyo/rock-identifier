<?php
// Simple test script to verify our environment loading works correctly

// Include the loadEnv function
function loadEnv() {
    $envFile = __DIR__ . '/.env';
    
    if (!file_exists($envFile)) {
        echo "ERROR: .env file not found at $envFile\n";
        die();
    }
    
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    
    foreach ($lines as $line) {
        // Skip comments and empty lines
        if (empty($line) || strpos($line, '#') === 0) {
            continue;
        }
        
        // Parse the line
        if (strpos($line, '=') !== false) {
            list($name, $value) = explode('=', $line, 2);
            $name = trim($name);
            $value = trim($value);
            
            // Remove quotes if they exist
            if (strpos($value, '"') === 0 && strrpos($value, '"') === strlen($value) - 1) {
                $value = substr($value, 1, -1);
            }
            
            // Set the environment variable
            putenv("$name=$value");
            $_ENV[$name] = $value;
        }
    }
    
    echo "Environment variables loaded successfully\n";
}

// Load environment variables
loadEnv();

// Test if variables loaded correctly
echo "OpenAI API Key (first 10 chars): " . substr(getenv('OPENAI_API_KEY'), 0, 10) . "...\n";
echo "Script Location: " . getenv('SCRIPT_LOCATION') . "\n";
echo "Secret Key (first 10 chars): " . substr(getenv('SHARED_SECRET_KEY'), 0, 10) . "...\n";
// Note: Custom prompt is now defined directly in the PHP file

// Check if our loadEnv function worked
echo "\nEnvironment Variables Test Complete!\n";
