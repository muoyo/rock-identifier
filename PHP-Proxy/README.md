# Rock Identifier Proxy Server

This PHP proxy script securely handles communication between the Rock Identifier iOS app and OpenAI's Vision API.

## Setup Instructions

1. **Deploy to Web Server**:
   - Upload the `openai_proxy.php` file to a web server with PHP support
   - Create a `tmp` directory in the same location and ensure it's writable:
     ```
     mkdir tmp
     chmod 777 tmp
     ```

2. **Configure Settings**:
   - Add your OpenAI API key to the `$openai_key` variable
   - Update the `$script_location` with your server URL
   - Verify the OpenAI prompt is correct
   - Change the `$shared_secret_key` to a unique value (must match the key in the iOS app)

3. **Update iOS App Connection**:
   - Update the `apiUrl` in `RockIdentificationService.swift` to point to your deployed proxy

## Security Notes

- The `openai_proxy.php` file contains your API key and should not be committed to Git
- It's already added to .gitignore to prevent accidental commits
- When deploying, you'll need to manually upload this file to your server
- Make a local backup of your configured proxy file in a secure location

## Security Features

- Employs a shared secret key system using MD5 hashing
- Only processes requests with valid authentication
- Temporary image files are deleted after 1 hour
- No user data is permanently stored on the server

## Troubleshooting

If you encounter connection issues:
1. Check that your OpenAI API key is valid
2. Verify the shared secret key matches between app and server
3. Ensure the tmp directory has correct permissions
4. Check your server's error logs for PHP-related issues

---

Based on Adam Lyttle's OpenAI Proxy PHP script, modified for Rock Identifier: Crystal ID.
