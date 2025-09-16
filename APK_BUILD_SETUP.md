# APK Build and Release Setup

This repository includes a GitHub Actions workflow to automatically build and release Android APK files for the Chaos Clinic app.

## 🚀 How to Use

### Method 1: Manual Trigger (Recommended)
1. Go to the Actions tab in your GitHub repository
2. Select "Build and Release APK" workflow
3. Click "Run workflow"
4. Enter the version number (e.g., `1.0.1`) and build number (e.g., `2`)
5. Click "Run workflow"

### Method 2: Git Tag Trigger
1. Create and push a git tag:
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
2. The workflow will automatically trigger and build the APK

## 🔐 Required Secrets for Release Signing

To properly sign the APK for production release, you need to set up the following GitHub secrets:

### 1. Generate a Release Keystore
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Convert Keystore to Base64
```bash
base64 upload-keystore.jks | tr -d '\n' > keystore.txt
```

### 3. Add GitHub Secrets
Go to Repository Settings > Secrets and variables > Actions, and add:

- `UPLOAD_KEYSTORE_BASE64`: Content of `keystore.txt` (base64 encoded keystore)
- `KEYSTORE_PASSWORD`: Password you used when creating the keystore
- `KEY_ALIAS`: Alias you used (usually "upload")
- `KEY_PASSWORD`: Key password (often same as keystore password)

## 📱 What the Workflow Does

1. **Setup Environment**: Installs Java 17 and Flutter 3.24.3
2. **Install Dependencies**: Runs `flutter pub get`
3. **Version Management**: Updates version in `pubspec.yaml`
4. **Signing Setup**: Configures release signing (if secrets are provided)
5. **Build APK**: Runs `flutter build apk --release`
6. **Create Release**: Creates a GitHub release with version tag
7. **Upload APK**: Attaches the APK to the release
8. **Artifact Storage**: Stores APK as GitHub artifact for 90 days

## 🏗️ Build Configuration

### Debug Build (Default)
If no signing secrets are provided, the APK will be signed with debug keys. This is suitable for testing but not for production release.

### Release Build (Production)
When proper signing secrets are configured, the APK will be signed with your release key, making it suitable for distribution.

## 📋 Build Output

The workflow generates:
- **GitHub Release**: With formatted release notes and version info
- **APK File**: Named `chaosclinic-v{VERSION}-{BUILD_NUMBER}.apk`
- **GitHub Artifact**: Downloadable from the Actions tab

## 🔧 Customization

### Changing Flutter Version
Edit the workflow file `.github/workflows/build-and-release-apk.yml`:
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.3'  # Change this version
```

### Changing Java Version
```yaml
- name: Setup Java
  uses: actions/setup-java@v4
  with:
    java-version: '17'  # Change this version
```

### Modifying Release Notes
Edit the `body` section in the "Create Release" step to customize the release notes template.

## 🐛 Troubleshooting

### Build Fails
1. Check that all dependencies in `pubspec.yaml` are compatible
2. Ensure Firebase configuration files are present
3. Verify that the Flutter version supports your dependencies

### Signing Issues
1. Verify all secrets are correctly set
2. Check keystore password and alias
3. Ensure the keystore file is properly base64 encoded

### Permission Issues
1. Ensure the repository has Actions enabled
2. Check that the GITHUB_TOKEN has sufficient permissions

## 📄 Files Created by This Setup

- `.github/workflows/build-and-release-apk.yml`: Main workflow file
- `APK_BUILD_SETUP.md`: This documentation file
- `android/key.properties`: Created during build (not committed)
- `android/app/upload-keystore.jks`: Created during build (not committed)

## 🔒 Security Notes

- Never commit keystore files or passwords to the repository
- Use GitHub secrets for all sensitive information
- The workflow automatically excludes signing files from git
- Debug-signed APKs are only suitable for testing, not production

---

After setting up the secrets and running the workflow, you'll have a production-ready APK available in your GitHub releases!