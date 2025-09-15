# Quick Start Guide: Testing the APK Build Workflow

## Immediate Testing (Without Signing Keys)

You can test the APK build workflow immediately without setting up production signing keys. The workflow will build a debug-signed APK that's perfect for testing.

### Step 1: Trigger the Workflow Manually
1. Go to your repository on GitHub
2. Click the **Actions** tab
3. Select **"Build and Release APK"** from the left sidebar
4. Click **"Run workflow"** (blue button on the right)
5. Fill in the inputs:
   - **Version number**: `1.0.1` (or any version you want)
   - **Build number**: `2` (or any build number)
6. Click **"Run workflow"** to start the build

### Step 2: Monitor the Build
- The workflow will take approximately 5-10 minutes to complete
- You can watch the progress in real-time by clicking on the running workflow
- Each step will show green checkmarks when completed

### Step 3: Download Your APK
After the workflow completes successfully:
1. Go to the **Releases** section of your repository (or click the link in the workflow output)
2. You'll find a new release with your version number
3. Download the `.apk` file attached to the release
4. Install it on your Android device

### Alternative: Using Git Tags
Instead of manual triggering, you can also create a git tag:
```bash
git tag v1.0.1
git push origin v1.0.1
```
This will automatically trigger the workflow.

## Expected Output

The workflow creates:
- ✅ **GitHub Release** with version info and description
- ✅ **APK File** named `chaosclinic-v{VERSION}-{BUILD_NUMBER}.apk`
- ✅ **GitHub Artifact** (downloadable from Actions tab for 90 days)

## Debug vs Production Signing

### Debug Build (Current)
- ✅ Works immediately without setup
- ✅ Perfect for testing and development
- ❌ Cannot be published to Google Play Store
- ❌ Shows "Unknown source" warning when installing

### Production Build (After Setup)
- ✅ Can be published to Google Play Store
- ✅ No security warnings when installing
- ⚙️ Requires keystore setup (see `APK_BUILD_SETUP.md`)

## Next Steps

1. **Test Now**: Run the workflow immediately to get your first APK
2. **Set Up Signing**: Follow `APK_BUILD_SETUP.md` for production-ready builds
3. **Customize**: Modify the workflow for your specific needs

## Troubleshooting Quick Issues

### Build Fails: Dependencies
If the build fails during `flutter pub get`, check that your `pubspec.yaml` dependencies are compatible with Flutter 3.24.3.

### Build Fails: Firebase
Ensure your Firebase configuration files (`google-services.json`) are properly committed to the repository.

### APK Won't Install
Debug APKs require enabling "Install from unknown sources" on your Android device.

---

**Ready to test?** Go to Actions → Build and Release APK → Run workflow!