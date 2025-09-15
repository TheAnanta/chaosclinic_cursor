#!/bin/bash

# APK Signing Setup Helper Script
# This script helps generate the required keystore and secrets for APK signing

set -e

echo "🔐 Chaos Clinic APK Signing Setup"
echo "=================================="
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ Error: keytool not found. Please install Java JDK."
    echo "   On Ubuntu/Debian: sudo apt install default-jdk"
    echo "   On macOS: brew install openjdk"
    exit 1
fi

# Function to generate keystore
generate_keystore() {
    echo "📝 Generating a new release keystore..."
    echo ""
    
    read -p "Enter your app name (default: Chaos Clinic): " APP_NAME
    APP_NAME=${APP_NAME:-"Chaos Clinic"}
    
    read -p "Enter your name/organization: " ORG_NAME
    read -p "Enter your organization unit (e.g., Development): " ORG_UNIT
    read -p "Enter your city: " CITY
    read -p "Enter your state/province: " STATE
    read -p "Enter your country code (e.g., US): " COUNTRY
    
    echo ""
    echo "🔑 Creating keystore (this will prompt for passwords)..."
    echo "   Note: Use a strong password and remember it!"
    echo ""
    
    keytool -genkey -v \
        -keystore upload-keystore.jks \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias upload \
        -dname "CN=$ORG_NAME, OU=$ORG_UNIT, O=$APP_NAME, L=$CITY, S=$STATE, C=$COUNTRY"
    
    echo ""
    echo "✅ Keystore created: upload-keystore.jks"
}

# Function to convert keystore to base64
convert_keystore() {
    if [ ! -f "upload-keystore.jks" ]; then
        echo "❌ Error: upload-keystore.jks not found. Please generate it first."
        return 1
    fi
    
    echo "📦 Converting keystore to base64..."
    base64 upload-keystore.jks | tr -d '\n' > keystore.txt
    echo "✅ Base64 keystore saved to: keystore.txt"
    echo ""
    echo "📋 Copy the content of keystore.txt to the UPLOAD_KEYSTORE_BASE64 secret in GitHub"
}

# Function to display GitHub secrets setup
show_secrets_setup() {
    echo ""
    echo "🔧 GitHub Secrets Setup"
    echo "======================="
    echo ""
    echo "Go to your repository settings > Secrets and variables > Actions"
    echo "Add the following repository secrets:"
    echo ""
    echo "1. UPLOAD_KEYSTORE_BASE64"
    echo "   Value: [Content of keystore.txt file]"
    echo ""
    echo "2. KEYSTORE_PASSWORD"
    echo "   Value: [Password you used when creating the keystore]"
    echo ""
    echo "3. KEY_ALIAS"
    echo "   Value: upload"
    echo ""
    echo "4. KEY_PASSWORD"
    echo "   Value: [Key password (usually same as keystore password)]"
    echo ""
}

# Function to show workflow usage
show_workflow_usage() {
    echo "🚀 Using the Workflow"
    echo "===================="
    echo ""
    echo "Method 1: Manual Trigger (Recommended)"
    echo "1. Go to Actions tab in your GitHub repository"
    echo "2. Select 'Build and Release APK' workflow"
    echo "3. Click 'Run workflow'"
    echo "4. Enter version number (e.g., 1.0.1) and build number (e.g., 2)"
    echo "5. Click 'Run workflow'"
    echo ""
    echo "Method 2: Git Tag Trigger"
    echo "1. git tag v1.0.1"
    echo "2. git push origin v1.0.1"
    echo ""
}

# Main menu
echo "Choose an option:"
echo "1. Generate new keystore"
echo "2. Convert existing keystore to base64"
echo "3. Show GitHub secrets setup"
echo "4. Show workflow usage instructions"
echo "5. Complete setup (all steps)"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        generate_keystore
        ;;
    2)
        convert_keystore
        ;;
    3)
        show_secrets_setup
        ;;
    4)
        show_workflow_usage
        ;;
    5)
        generate_keystore
        echo ""
        convert_keystore
        show_secrets_setup
        show_workflow_usage
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🎉 Setup complete! Your APK build workflow is ready to use."
echo ""
echo "⚠️  Important Security Notes:"
echo "   - Keep your keystore file safe and backed up"
echo "   - Never commit keystore files or passwords to git"
echo "   - Use strong passwords for production keystores"
echo ""
echo "📚 For more information, see APK_BUILD_SETUP.md"