<?php
    // Set higher memory limit
    ini_set('memory_limit', '512M');
    
    // Enable error reporting for debugging
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
    
    // Set up logging
    function logError($message) {
        $logFile = 'error_log.txt';
        $timestamp = date('[Y-m-d H:i:s]');
        file_put_contents($logFile, "$timestamp $message\n", FILE_APPEND);
    }
    
    // Load environment variables
    function loadEnv() {
        $envFile = __DIR__ . '/.env';
        
        if (!file_exists($envFile)) {
            logError("ERROR: .env file not found at $envFile");
            die("Environment file not found. Please create a .env file from .env.example");
        }
        
        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        
        foreach ($lines as $line) {
            // Skip comments and empty lines
            if (empty($line) || strpos($line, '#') === 0) {
                continue;
            }
            
            // Parse the line
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
        
        logError("Environment variables loaded successfully");
    }
    
    // Load environment variables at script start
    loadEnv();
    
    // Log script execution with more details
    logError("====== New API Request Started: " . date('Y-m-d H:i:s') . " ======");
    logError("Remote IP: " . ($_SERVER['REMOTE_ADDR'] ?? 'unknown'));
    logError("User Agent: " . ($_SERVER['HTTP_USER_AGENT'] ?? 'unknown'));
    logError("Script execution started");
    
    // Add a global timeout at the script start
    set_time_limit(300); // 5 minute timeout
    $startTime = microtime(true);

    // Rock Identifier: Crystal ID Proxy Script
    // Muoyo Okome

    //Get environment variables
    $openai_key = getenv('OPENAI_API_KEY');
    $script_location = getenv('SCRIPT_LOCATION');
    $shared_secret_key = getenv('SHARED_SECRET_KEY');
    
    // Verify environment variables are loaded
    if (!$openai_key || !$script_location || !$shared_secret_key) {
        logError("ERROR: Required environment variables not found");
        die("Required environment variables not found in .env file. Please check your configuration.");
    }
    
    // Extract JSON from markdown code blocks or any surrounding text
    function cleanAndValidateJson($jsonString) {
        // Log the original JSON for debugging
        logError("Original JSON before cleaning (first 500 chars): " . substr($jsonString, 0, 500));
        
        // Remove any HTML comments
        $jsonString = preg_replace('/<!--.*?-->/s', '', $jsonString);
        
        // Extract JSON from markdown code blocks
        if (strpos($jsonString, '```') !== false) {
            if (preg_match('/```(?:json)?\s*([\s\S]*?)\s*```/s', $jsonString, $matches)) {
                $jsonString = trim($matches[1]);
            }
        }
        
        // Extract just the JSON object if the response contains other text
        if (preg_match('/({(?:[^{}]|(?R))*})/s', $jsonString, $matches)) {
            $jsonString = $matches[0];
        }
        
        // Fix common JSON formatting issues
        
        // Fix the "usees" typo
        $jsonString = str_replace('"usees":', '"uses":', $jsonString);
        $jsonString = str_replace('"usees" :', '"uses":', $jsonString);
        
        // Fix extra escaped quotes in property names
        $jsonString = preg_replace('/"\\"([^"]+)\\"\s*:/', '"$1":', $jsonString);
        
        // Fix missing quotes around property names
        $jsonString = preg_replace('/([{,])\s*(\w+)\s*:/', '$1"$2":', $jsonString);
        
        // Fix missing commas between properties
        $jsonString = preg_replace('/}(\s*)"/', '},$1"', $jsonString);
        
        // Fix trailing commas
        $jsonString = preg_replace('/,\s*}/', '}', $jsonString);
        $jsonString = preg_replace('/,\s*\]/', ']', $jsonString);
        
        // Fix strings with colons at the beginning (environment: ": Forms from...") 
        $jsonString = preg_replace('/"(environment|geologicalAge|formationProcess)"\s*:\s*":\s*/', '"$1":"', $jsonString);
        
        // Fix percentage fields that should be numbers, not strings
        $jsonString = preg_replace('/"percentage"\s*:\s*"([0-9.]+)"/', '"percentage": $1', $jsonString);
        
        // Fix specific gravity with tilde
        $jsonString = preg_replace('/"specificGravity"\s*:\s*"~([0-9.]+)"/', '"specificGravity": "~$1"', $jsonString);
        
        // Handle common array formatting issues
        $jsonString = preg_replace('/"([^"]+)"\s*:\s*\["\s*"\]/', '"$1": []', $jsonString);
        
        // Handle null values in elements array
        $jsonString = preg_replace('/"elements"\s*:\s*\[\s*{\s*"name"\s*:\s*null\s*,\s*"symbol"\s*:\s*null\s*,\s*"percentage"\s*:\s*null\s*}\s*\]/', '"elements": []', $jsonString);
        
        // Log the cleaned JSON for debugging
        logError("Cleaned JSON (first 500 chars): " . substr($jsonString, 0, 500));
        
        // Validate the JSON
        $decodedJson = json_decode($jsonString, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            logError("JSON validation successful");
            return json_encode($decodedJson, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
        
        // If validation fails, log the error and return the original string
        logError("JSON validation failed: " . json_last_error_msg());
        return $jsonString;
    }
    
    //CONFIGURE YOUR CUSTOM PROMPT:
$custom_prompt = "You are a geological analysis AI specialized in rock and mineral identification. You MUST respond with PERFECTLY VALID JSON that follows strict JSON formatting rules.

Analyze the image and provide identification in valid JSON format matching this structure exactly:
{
    \"name\": \"Name of rock/mineral\",
    \"category\": \"Rock/Mineral/Crystal/Gemstone\",
    \"confidence\": 0.95,
    \"physicalProperties\": {
        \"color\": \"Color description\",
        \"hardness\": \"Mohs scale value\",
        \"luster\": \"Type of luster\",
        \"streak\": \"Streak color\",
        \"transparency\": \"Transparency level\",
        \"crystalSystem\": \"Crystal system if applicable\",
        \"cleavage\": \"Cleavage description\",
        \"fracture\": \"Fracture type\",
        \"specificGravity\": \"Specific gravity value\",
        \"additionalProperties\": {\"property1\": \"value1\"}
    },
    \"chemicalProperties\": {
        \"formula\": \"Chemical formula\",
        \"composition\": \"Main components\",
        \"elements\": [
            {\"name\": \"Element name\", \"symbol\": \"Element symbol\", \"percentage\": 80}
        ],
        \"mineralsPresent\": [\"Mineral 1\", \"Mineral 2\"],
        \"reactivity\": \"Any notable chemical reactions\",
        \"additionalProperties\": {\"property1\": \"value1\"}
    },
    \"formation\": {
        \"formationType\": \"Formation type\",
        \"environment\": \"Formation environment\",
        \"geologicalAge\": \"Age if known\",
        \"commonLocations\": [\"Location 1\", \"Location 2\"],
        \"associatedMinerals\": [\"Associated Mineral 1\", \"Associated Mineral 2\"],
        \"formationProcess\": \"How it forms\",
        \"additionalInfo\": {\"info1\": \"value1\"}
    },
    \"uses\": {
        \"industrial\": [\"Use 1\", \"Use 2\"],
        \"historical\": [\"Historical use\"],
        \"modern\": [\"Modern use\"],
        \"metaphysical\": [\"Metaphysical property\"],
        \"funFacts\": [\"Interesting fact 1\", \"Interesting fact 2\"],
        \"additionalUses\": {\"use1\": \"value1\"}
    }
}

For errors, use this format:
{\"error\":\"Reason\",\"suggestions\":[\"Suggestion 1\", \"Suggestion 2\"]}

STRICT JSON FORMATTING RULES:
1. Your response MUST be PURE JSON with NO explanatory text before or after
2. DO NOT include markdown formatting, code blocks, or conversational language
3. All property names must be in double quotes: \"property\": value
4. All string values must be in double quotes: \"property\": \"value\"
5. Never use escaped quotes inside property names: \"property\": value (NOT \\\"property\\\": value)
6. Array elements must be separated by commas: [\"value1\", \"value2\"]
7. Object properties must be separated by commas: {\"prop1\": \"val1\", \"prop2\": \"val2\"}
8. No trailing commas at the end of arrays or objects: {\"prop\": \"val\"} (NOT {\"prop\": \"val\",})
9. Pay special attention to the formation section - use standard JSON formatting
10. Always use \"uses\" (never \"usees\") for the uses object
11. If a property has no value, use null instead of an empty string: \"formula\": null
12. Numeric values like confidence should not have quotes: \"confidence\": 0.95 (NOT \"confidence\": \"0.95\")
13. Validate your entire JSON with a JSON validator before responding
14. Ensure all brackets and quotes are balanced and properly closed";
    

    //check if the client has provided messages:
if(!@$_POST['messages']) {
    logError("ERROR: No messages parameter provided in request");
    header('HTTP/1.1 400 Bad Request');
    echo json_encode(["error" => "No messages parameter provided", "suggestions" => ["Please include a messages parameter in your request"]]);
    exit();
}

// Log raw message data for debugging
logError("Raw messages data: " . $_POST['messages']);
logError("Request info: " . print_r($_SERVER, true));

// Check that the secret_key hash is correct
if ($shared_secret_key && md5($_POST['messages'].$shared_secret_key) != @$_POST['hash']) {
    $expected = md5($_POST['messages'].$shared_secret_key);
    $received = @$_POST['hash'];
    logError("Authentication failed: incorrect shared_secret_key hash");
    logError("Expected: $expected");
    logError("Received: $received");
    
    header('HTTP/1.1 401 Unauthorized');
    echo json_encode(["error" => "Authentication failed", "suggestions" => ["Ensure you're using the correct API key"]]);
    exit();
}
    
    // Make sure tmp directory exists
    if (!file_exists('tmp')) {
        mkdir('tmp', 0777, true);
        logError("Created tmp directory");
    }
    
    // Verify the script location is valid
    function verifyScriptLocation($url) {
        $testUrl = $url . '/tmp/';
        logError("Verifying script location: $testUrl");
        
        // Create a test image if tmp directory exists
        if (file_exists('tmp') || mkdir('tmp', 0777, true)) {
            $testFile = 'tmp/test.txt';
            file_put_contents($testFile, 'test');
            
            // Test if we can reach this URL
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $testUrl);
            curl_setopt($ch, CURLOPT_NOBODY, true);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_exec($ch);
            $responseCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            if ($responseCode >= 200 && $responseCode < 400) {
                logError("Script location verified: $testUrl (HTTP $responseCode)");
                return true;
            } else {
                logError("Script location check FAILED: $testUrl (HTTP $responseCode)");
                return false;
            }
        }
        
        logError("Could not create test file in tmp directory");
        return false;
    }
    
    // Verify the script location
    verifyScriptLocation($script_location);

    class Openai{
        // We're directly using the API key in the request method
    
        public function request($messages, $max_tokens){ 
            global $openai_key;
            logError("Preparing OpenAI API request");
            
            try {
                // Try different models in order of preference
                // OpenAI has been known to change model names and deprecate them
                $models = [
                    "gpt-4o",           // Best option - newest model with vision capabilities
                    "gpt-4-vision-preview", // Legacy model with vision capabilities
                    "gpt-4-turbo-vision"    // Alternative name sometimes used
                ];
                
                $request_body = [
                "messages" => $messages,
                "max_tokens" => $max_tokens,
                "temperature" => 0.5,  // Lower temperature for more precise identification
                "top_p" => 1,
                "presence_penalty" => 0.5,
                "frequency_penalty"=> 0.5,
                "stream" => false,
                "model" => $models[0],  // Use first model by default
                ];
        
                $response = null;
                $lastError = "";
                
                // Try each model in sequence until one works
                foreach ($models as $model) {
                    $request_body["model"] = $model;
                    $postfields = json_encode($request_body);
                    
                    logError("Trying model: $model");
                    
                    $curl = curl_init();
                    curl_setopt_array($curl, [
                    CURLOPT_URL => "https://api.openai.com/v1/chat/completions",
                    CURLOPT_RETURNTRANSFER => true,
                    CURLOPT_FOLLOWLOCATION => true,
                    CURLOPT_ENCODING => "",
                    CURLOPT_MAXREDIRS => 10,
                    CURLOPT_CONNECTTIMEOUT => 30,
                    CURLOPT_TIMEOUT => 180,  // Increased timeout for more reliability
                    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
                    CURLOPT_CUSTOMREQUEST => "POST",
                    CURLOPT_POSTFIELDS => $postfields,
                    CURLOPT_HTTPHEADER => [
                        'Content-Type: application/json',
                        'Authorization: Bearer ' . $openai_key
                    ],
                    CURLOPT_VERBOSE => true,
                    ]);
            
                    logError("Sending request to OpenAI with model $model");
                    // Don't echo debug info
                    $response = curl_exec($curl);
                    $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
                    logError("OpenAI API HTTP response code: $httpCode for model $model");
                    
                    $err = curl_error($curl);
                    if ($err) {
                        logError("cURL Error with $model: $err");
                        $lastError = $err;
                    }
            
                    curl_close($curl);
                    
                    // Check if the response is usable
                    $decoded = json_decode($response, true);
                    
                    // If there's no error or the error isn't about the model, break the loop
                    if (!isset($decoded['error']) || 
                        (isset($decoded['error']['message']) && !strpos($decoded['error']['message'], 'deprecated'))) {
                        logError("Model $model succeeded or failed for reasons other than deprecation");
                        break;
                    }
                    
                    logError("Model $model failed: " . (isset($decoded['error']['message']) ? $decoded['error']['message'] : 'Unknown error'));
                }
        
                if ($lastError) {
                    throw new Exception("cURL error: $lastError");
                } 
                
                $decoded = json_decode($response, true);
                if ($decoded === null) {
                    logError("Failed to decode API response: " . json_last_error_msg());
                    logError("Response preview: " . substr($response, 0, 500));
                    
                    // Return a formatted error response that the app can understand
                    $errorResponse = array(
                        "error" => "Image analysis not possible",
                        "suggestions" => [
                            "Ensure the image is clear and well-lit",
                            "Make sure your rock is the main subject in the photo",
                            "Try a different angle or lighting condition"
                        ],
                        "debug_info" => substr($response, 0, 500)
                    );
                    
                    // Log the full details for debugging
                    logError("Invalid API response: " . json_last_error_msg());
                    logError("Response preview: " . substr($response, 0, 500));
                    
                    return $errorResponse;
                }
                
                // Make sure we have content in the response
                if (empty($decoded['choices']) || empty($decoded['choices'][0]['message']['content'])) {
                    logError("Response has no content: " . json_encode($decoded));
                    return array(
                        'error' => 'No content in API response',
                        'suggestions' => [
                            'Try with a clearer image',
                            'Make sure the rock is clearly visible'
                        ]
                    );
                }
                
                return $decoded;
            } 
            catch (Exception $e) {
                logError("Error in API request: " . $e->getMessage());
                return array('error' => array('message' => $e->getMessage()));
            }
        }
    
    }

    //parses single message with image_data
function add_message_image_data($role,$data) {
global $script_location;

logError("Inside add_message_image_data function");

try {
    // The data comes as a percent-encoded string, we need to convert it to binary
    // First, we convert each %XX to the corresponding byte
    logError("Raw image data length: " . strlen($data));
    
    // Check the beginning of the data to see format
    $dataPrefix = substr($data, 0, 20);
    logError("Data prefix: $dataPrefix");
    
    // Process the percent-encoded string
    if (strpos($data, '%') !== false) {
        logError("Detected percent-encoded image data");
        // Convert percent encoding to binary
        $binaryData = '';
        $length = strlen($data);
        
        for ($i = 0; $i < $length; $i++) {
            if ($data[$i] === '%' && $i + 2 < $length) {
                $hex = substr($data, $i + 1, 2);
                $binaryData .= chr(hexdec($hex));
                $i += 2;
            } else {
                $binaryData .= $data[$i];
            }
        }
    } else {
        // If not percent-encoded, try using it directly
        logError("Using direct binary data");
        $binaryData = $data;
    }
    
    // Generate a unique hash for the image
    $hash = md5($binaryData);
    logError("Image data hash: $hash");

    // Create tmp directory if it doesn't exist
    if(!file_exists("tmp")) {
        mkdir("tmp", 0777, true);
        logError("Created tmp directory");
    }
    
    // Save the image to a file
    $filePath = "tmp/{$hash}.jpg";
    if (file_put_contents($filePath, $binaryData) === false) {
        logError("Failed to save image to $filePath");
        throw new Exception("Failed to write image data to file");
    }
    
    logError("Saved image to $filePath, size: " . filesize($filePath) . " bytes");
    
    // Check if the file is a valid image
    $imageInfo = @getimagesize($filePath);
    if ($imageInfo === false) {
        logError("WARNING: The saved file doesn't appear to be a valid image");
    } else {
        logError("Image dimensions: {$imageInfo[0]}x{$imageInfo[1]}, type: {$imageInfo['mime']}");
    }

    $item = new stdClass();
    $item->role = $role;

    // Create the full URL for the image
    $imageUrl = "$script_location/tmp/{$hash}.jpg";
    
    // Simplified content structure for gpt-4o
    $item->content = [
        ["type" => "text", "text" => "What type of rock is this? Analyze and identify the rock ONLY in a valid JSON format. IMPORTANT: Follow these formatting rules strictly:
1. Every field name MUST be in double quotes (example: \"name\": \"value\")
2. Do not put quotation marks around numeric values for 'confidence' (example: \"confidence\": 0.95)
3. Use double quotes around all string values (example: \"color\": \"red\")
4. All percentages must be strings in quotes (example: \"percentage\": \"~50\")
5. The 'uses' field (not 'usees') must be properly formatted
6. Never use escaped quotes in property names (WRONG: \\\"geologicalAge\\\")  
7. Validate your entire JSON before responding
8. Ensure all quotes, brackets, and braces are balanced and matched
9. Your entire response must be valid JSON with no errors
10. Return only valid JSON with no other text"],
        ["type" => "image_url", "image_url" => ["url" => $imageUrl]]
    ];
    
    logError("Image URL set to: $imageUrl");
    logError("Successfully created message object with image");
    return $item;
} 
catch (Exception $e) {
    logError("Error in add_message_image_data: " . $e->getMessage());
    // Return a basic message without the image if there's an error
    $item = new stdClass();
    $item->role = $role;
    $item->content = [["type" => "text", "text" => "[Error processing image]"]];
    return $item;
}
}
    
    //parses single message with text
    function add_message($role,$text) {
        $item = new stdClass();
        $item->role = $role;

        $content = new stdClass();
        $content->type = "text";
        $content->text = $text;

        $item->content[] = $content;

        return $item;
    }

    //parses all received messages
    function parse_messages($messages) {
        global $custom_prompt;
        
        logError("Starting parse_messages with message count: " . count($messages));
        logError("Message structure: " . json_encode($messages));
        
        // Add system prompt as the first message
        $parsedMessages = [add_message("system", "$custom_prompt")];

        $i = 0;
        foreach ($messages as $message) {
            logError("Processing message $i: " . json_encode($message));
            
            // For each message in the array, we want to create a single message object with both text and image if provided
            $role = isset($message['role']) ? $message['role'] : 'user';
            
            // Check if this message has an image
            if (isset($message['image']) && !empty($message['image'])) {
                // If it has an image, create a message with both image and text content
                $parsedMessages[] = add_message_image_data($role, $message['image']);
                logError("Added image data for message $i");
            } 
            // If no image but has text message, add a text-only message
            else if (isset($message['message']) && !empty($message['message'])) {
                $parsedMessages[] = add_message($role, $message['message']);
                logError("Added text-only data for message $i: {$message['message']}");
            }
            else if (isset($message['content']) && !empty($message['content'])) {
                // If neither image nor message, check for content field
                $parsedMessages[] = add_message($role, $message['content']);
                logError("Added content field data for message $i: {$message['content']}");
            }
            else {
                logError("Message $i has no recognizable content");
            }
            
            $i++;
        }
        
        logError("Completed parse_messages with " . count($parsedMessages) . " messages");
        return $parsedMessages;
    }




    //this is where the logic starts:
    try {
    logError("Starting to process message request");
    
    // Log debug info but DON'T echo to output
    logError("Debug info: Processing request");
    
    //process the received messages
    $decodedMessages = json_decode(@$_POST['messages'], true);
    if ($decodedMessages === null) {
        logError("Error decoding JSON from _POST['messages']: " . json_last_error_msg());
        echo json_encode([
            "error" => "Failed to decode JSON messages", 
            "suggestions" => ["Ensure your messages are properly formatted as JSON"]
        ]);
        throw new Exception("Failed to decode JSON messages");
    }
    
    logError("Message count: " . count($decodedMessages));
    
    // Add a sanity check for the image data size
    $imageSizeWarningThreshold = 10 * 1024 * 1024; // 10MB
    foreach ($decodedMessages as $message) {
        if (isset($message['image'])) {
            $imageSize = strlen($message['image']);
            logError("Image data size: " . $imageSize . " bytes");
            
            if ($imageSize > $imageSizeWarningThreshold) {
                logError("WARNING: Very large image detected (" . round($imageSize / 1024 / 1024, 2) . " MB)");
                
                // If the image is too large, send a meaningful error response
                if ($imageSize > 20 * 1024 * 1024) { // 20MB
                    $errorJson = json_encode([
                        "error" => "Image too large for processing",
                        "suggestions" => [
                            "Please resize your image to under 10MB",
                            "Try taking a photo with lower resolution",
                            "Crop the image to focus on just the rock"
                        ]
                    ]);
                    print($errorJson);
                    exit;
                }
            }
        }
    }
    
    $messages = parse_messages($decodedMessages);
    logError("Messages parsed successfully");
    
    // Test OpenAI connection before sending the actual request
    logError("Testing OpenAI connection");
    try {
        // Create a simple test query to verify OpenAI connectivity
        $testMessages = [add_message("user", "Test connection")];
        $q = New Openai();
        $testResponse = $q->request($testMessages, 50); // Very small token limit for test
        
        if (!isset($testResponse['choices']) && isset($testResponse['error'])) {
            logError("OpenAI test connection failed: " . json_encode($testResponse));
            throw new Exception("Failed to connect to OpenAI API: " . ($testResponse['error']['message'] ?? "Unknown error"));
        }
        
        logError("OpenAI connection test successful");
        
        //connects to openai and returns result for the real request
        logError("Sending request to OpenAI API");
        $openai = $q->request($messages, 2000);  // Increased token limit for detailed responses
    } catch (Exception $e) {
        logError("OpenAI request error: " . $e->getMessage());
        throw $e;
    }
    
    // Make sure we got a valid response
    if (empty($openai) || !is_array($openai)) {
        logError("ERROR: OpenAI API returned an empty or invalid response");
        echo json_encode([
            "error" => "Empty or invalid response from API", 
            "suggestions" => [
                "Try again in a few moments", 
                "Ensure your image is clear and contains a rock specimen"
            ]
        ]);
        exit();
    }
    
    // Debug what we got back
    logError("OpenAI API response received: " . json_encode($openai, JSON_PARTIAL_OUTPUT_ON_ERROR));
    
        // Add more reliable JSON extraction and validation
        if (isset($openai['choices'][0]['message']['content'])) {
            $message = $openai['choices'][0]['message']['content'];
            logError("Success! Response content length: " . strlen($message));
            
            // Apply our validation and cleaning function
            $message = cleanAndValidateJson($message);
            logError("Cleaned and validated JSON - length: " . strlen($message));
            
            // Parse the JSON for additional validation
            $jsonData = json_decode($message, true);
            
            if (json_last_error() === JSON_ERROR_NONE && $jsonData !== null) {
                // The JSON is valid, we can use it directly
                logError("JSON validation successful");
                print($message);
                exit;
            }
            
            // If JSON validation failed, try the original extraction methods
            // Strip out any HTML comments and markdown code blocks before serving the response
            $message = preg_replace('/<!--.*?-->/s', '', $message);
            $message = preg_replace('/```json\s*([\s\S]*?)\s*```/s', '$1', $message);
            $message = preg_replace('/```([\s\S]*?)```/s', '$1', $message);
            
            // Trim whitespace from the beginning and end
            $message = trim($message); 
            
            // Extract JSON from the message if it's wrapped in text
            $jsonPattern = '/\{(?:[^{}]|(?R))*\}/s';  // Recursive pattern for nested JSON
            if (preg_match($jsonPattern, $message, $matches)) {
                $potentialJson = $matches[0];
                logError("Extracted potential JSON: " . substr($potentialJson, 0, 100) . "...");
                
                // Now apply a series of fixes to make the JSON valid
                $jsonToFix = $potentialJson;
                
                // Fix the "usees" typo
                $jsonToFix = str_replace('"usees":', '"uses":', $jsonToFix);
                $jsonToFix = str_replace('"usees" :', '"uses":', $jsonToFix);
                
                // Fix extra escaped quotes in property names
                $jsonToFix = preg_replace('/"\\"([^"]+)\\"\s*:/', '"$1":', $jsonToFix);
                
                // Fix extra quotes around values that shouldn't have them
                $jsonToFix = preg_replace('/:\s*"\\"([^"]+)\\""/', ': "$1"', $jsonToFix);
                
                // Fix arrays with extra quotes
                $jsonToFix = preg_replace('/"\\"([^"]+)\\"\s*:\s*\[(.+?)\]\\""/', '"$1": [$2]', $jsonToFix);
                
                // Fix trailing commas
                $jsonToFix = preg_replace('/,\s*}/', '}', $jsonToFix);
                $jsonToFix = preg_replace('/,\s*\]/', ']', $jsonToFix);
                
                // Verify the JSON is now valid
                $verifyJson = json_decode($jsonToFix, true);
                if (json_last_error() === JSON_ERROR_NONE && $verifyJson !== null) {
                    logError("JSON verified and fixed successfully");
                    
                    // Re-encode it with proper options to ensure consistency
                    $finalJson = json_encode($verifyJson, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
                    print($finalJson);
                    exit;
                } else {
                    // If our automatic fixes failed, just return the extracted JSON
                    // The Swift client has more advanced repair capabilities
                    logError("JSON validation failed after fixes: " . json_last_error_msg());
                    print($potentialJson);
                    exit;
                }
            }
            
            // If the content starts with '{' and ends with '}', it's probably valid JSON
            if (substr($message, 0, 1) === '{' && substr($message, -1) === '}') {
                logError("Returning JSON response directly");
                print($message);
                exit;
            }
            
            // If we couldn't find valid JSON, return an error
            logError("No valid JSON structure found");
            $errorJson = json_encode([
                "error" => "No valid JSON structure found in the response",
                "suggestions" => [
                    "Try taking a clearer photo of the rock",
                    "Ensure good lighting and focus",
                    "Position the rock against a neutral background"
                ],
                "rawResponse" => substr($message, 0, 200) . "..."
            ]);
            print($errorJson);
        }
        else {
            $errorMsg = isset($openai['error']['message']) ? $openai['error']['message'] : "Unknown API error";
            logError("OpenAI API error: $errorMsg");
            print(json_encode(array("error" => "API error: $errorMsg")));
        }
    }
    catch (Exception $e) {
        $errorMessage = "Critical error: " . $e->getMessage();
        logError($errorMessage);
        print(json_encode(array("error" => $errorMessage)));
    }

    // Delete temporary files older than 10 minutes to avoid caching issues
    $files = glob('tmp/*.jpg');
    $now = time();

    foreach ($files as $file) {
        if (is_file($file)) {
            if ($now - filemtime($file) >= 600) { // 600 seconds = 10 minutes
                unlink($file);
                logError("Deleted temporary file: $file");
            }
        }
    }
    
    // Also clear the error log if it gets too large (over 5MB)
    $logFile = 'error_log.txt';
    if (file_exists($logFile) && filesize($logFile) > 5 * 1024 * 1024) { // 5MB
        // Keep the last 1000 lines only
        $lines = file($logFile);
        $lines = array_slice($lines, -1000);
        file_put_contents($logFile, implode('', $lines));
        logError("Trimmed log file to last 1000 lines");
    }

?>