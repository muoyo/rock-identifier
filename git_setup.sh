#!/bin/bash

# Navigate to the project directory
cd /Users/mokome/Dev/rock-identifier

# Create a backup of any sensitive files that shouldn't be committed
echo "Creating backup of sensitive files..."
mkdir -p ~/.backups/rock-identifier
cp -f PHP-Proxy/openai_proxy.php ~/.backups/rock-identifier/

# Initialize Git repository
echo "Initializing Git repository..."
git init

# Add all files to staging
echo "Adding files to git..."
git add .

# Create initial commit
echo "Creating initial commit..."
git commit -m "Initial commit: Rock Identifier Phase 1 implementation"

# Set up remote repository
echo "Setting up remote repository..."
git remote add origin git@github.com:muoyo/rock-identifier.git

# Push to the main branch
# Note: If you prefer using 'main' instead of 'master', you can use:
# git branch -M main
# git push -u origin main
echo "Pushing to remote repository..."
git branch -M main
git push -u origin main

echo "Git repository set up complete!"
echo "Remote: github.com/muoyo/rock-identifier"
echo ""
echo "IMPORTANT: Your sensitive files have been backed up to ~/.backups/rock-identifier/"
echo "These files are not included in the git repository for security reasons."
echo "Remember to manually upload them when deploying your server."
