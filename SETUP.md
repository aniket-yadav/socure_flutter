# Complete Setup Guide for Socure Flutter Plugin

This guide provides step-by-step instructions for integrating the `socure_flutter` plugin into your Flutter application.

## Prerequisites

- Flutter 3.3.0+
- Dart SDK 3.9.2+
- **Android**: minSdkVersion 24+, Android Studio
- **iOS**: iOS 13.0+, Xcode 14.1+
- Socure SDK credentials (SDK key and transaction token generation)

## Step 1: Add Plugin Dependency

### Option A: Local Path (During Development)

In your app's `pubspec.yaml`:

```yaml
dependencies:
  socure_flutter:
    path: /path/to/socure_flutter  # Adjust path accordingly
```

### Option B: Git Repository (Recommended for Teams)

```yaml
dependencies:
  socure_flutter:
    git:
      url: https://github.com/YOUR_USERNAME/socure_flutter.git
      ref: main
```

Then run:
```bash
flutter pub get
```

## Step 2: Android Setup

### 2.1 Add Socure Maven Repository

**IMPORTANT**: The plugin requires the Socure SDK from their Maven repository. You must add this to your app's build configuration.

#### For `android/build.gradle.kts` (Kotlin DSL):

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        // Add Socure Maven repository
        maven { url = uri("https://sdk.socure.com") }
    }
}
```

#### For `android/build.gradle` (Groovy DSL):

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        // Add Socure Maven repository
        maven { url 'https://sdk.socure.com' }
    }
}
```

### 2.2 Set Minimum SDK Version

In `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Required minimum
        // ...
    }
}
```

### 2.3 Request Permissions at Runtime

The plugin includes required permissions in its manifest, but you need to request them at runtime. Use the `permission_handler` package:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermissions() async {
  final camera = await Permission.camera.request();
  final photos = await Permission.photos.request();

  return camera.isGranted && photos.isGranted;
}
```

## Step 3: iOS Setup

### 3.1 Update Podfile

**CRITICAL**: The Socure SDK uses static frameworks. Update your `ios/Podfile`:

```ruby
platform :ios, '13.0'

target 'Runner' do
  use_frameworks! :linkage => :static  # REQUIRED for Socure SDK

  # Your other pod configurations...
end
```

### 3.2 Add Camera Permission

In `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This application requires use of your camera in order to capture your identity documents.</string>
```

### 3.3 Install Pods

```bash
cd ios
pod install
cd ..
```

## Step 4: Backend Integration

**SECURITY CRITICAL**: Never expose your Socure API secret key in the mobile app. Always generate transaction tokens on your backend.

### 4.1 Backend: Generate Transaction Token

```javascript
// Example: Node.js backend
const axios = require('axios');

async function generateTransactionToken(userData) {
  const response = await axios.post(
    'https://service.socure.com/api/5.0/documents/request',
    {
      config: {
        // Optional configuration
      },
      firstName: userData.firstName,
      surName: userData.lastName,
      // ... other PII data
    },
    {
      headers: {
        'Authorization': `SocureApiKey ${process.env.SOCURE_API_KEY}`,
        'Content-Type': 'application/json'
      }
    }
  );

  return response.data.data.docvTransactionToken;
}
```

### 4.2 Mobile App: Use the Plugin

```dart
import 'package:socure_flutter/socure_flutter.dart';

class DocumentVerificationScreen extends StatefulWidget {
  @override
  _DocumentVerificationScreenState createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  final _socure = SocureFlutter();

  Future<void> _startVerification() async {
    try {
      // 1. Get transaction token from YOUR backend
      final token = await _getTokenFromBackend();

      // 2. Configure Socure options
      final options = SocureDocVOptions(
        sdkKey: 'YOUR_PUBLIC_SDK_KEY',  // From Socure dashboard
        transactionToken: token,
        useSocureGov: false,  // true for government cloud
      );

      // 3. Launch DocV
      final result = await _socure.launchDocV(options);

      // 4. Handle result
      result.when(
        success: (data) {
          print('Success! Device session token: ${data.deviceSessionToken}');
          // Send token to backend for verification
          _sendToBackend(data.deviceSessionToken);
        },
        failure: (error) {
          print('Error: ${error.userFriendlyMessage}');
          _handleError(error);
        },
      );
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<String> _getTokenFromBackend() async {
    // Call your backend API
    final response = await http.post(
      Uri.parse('https://your-api.com/generate-token'),
      headers: {'Authorization': 'Bearer ${userAuthToken}'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['transactionToken'];
    } else {
      throw Exception('Failed to get transaction token');
    }
  }

  Future<void> _sendToBackend(String deviceSessionToken) async {
    // Send device session token to your backend
    await http.post(
      Uri.parse('https://your-api.com/verify-document'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'deviceSessionToken': deviceSessionToken}),
    );
  }

  void _handleError(SocureDocVFailure error) {
    switch (error.errorType) {
      case SocureDocVErrorType.userCanceled:
        // User canceled - maybe show different message
        break;
      case SocureDocVErrorType.cameraPermissionDenied:
        // Show permission settings dialog
        _showPermissionDialog();
        break;
      case SocureDocVErrorType.invalidToken:
        // Token expired, get new one
        break;
      default:
        // Show generic error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.userFriendlyMessage)),
        );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text('Please enable camera permission in Settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Use permission_handler package to open settings
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document Verification')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startVerification,
          child: Text('Start Verification'),
        ),
      ),
    );
  }
}
```

## Step 5: Test the Integration

### Android
```bash
flutter run  # For connected device
flutter build apk --debug  # Build APK
```

### iOS
```bash
flutter run  # For connected device/simulator
flutter build ios --no-codesign  # Build for device (requires Mac)
```

## Common Issues

### Android: "Could not find com.socure.android:docv-capture"

**Solution**: Ensure you've added `maven { url 'https://sdk.socure.com' }` to your app's `android/build.gradle` file.

### iOS: "Pods-Runner target has transitive dependencies"

**Solution**: Use static linkage in Podfile: `use_frameworks! :linkage => :static`

### iOS: Module 'SocureDocV' not found

**Solution**: Run `cd ios && pod install && cd ..`

### Camera permission denied

**Solution**: Request permissions at runtime using the `permission_handler` package before launching DocV.

## Architecture Flow

```
1. User initiates verification
2. App calls backend to generate transaction token
3. Backend calls Socure API with API secret key
4. Backend returns transaction token to app
5. App launches Socure DocV SDK with token
6. User captures document
7. DocV returns device session token
8. App sends device session token to backend
9. Backend fetches verification results from Socure
10. Backend processes results and updates user status
```

## Security Best Practices

1. ✅ **DO**: Generate transaction tokens on your backend
2. ✅ **DO**: Store API keys in environment variables on backend
3. ✅ **DO**: Use HTTPS for all communication
4. ✅ **DO**: Implement token expiration handling
5. ❌ **DON'T**: Embed Socure API secret keys in mobile app
6. ❌ **DON'T**: Commit API keys to version control
7. ❌ **DON'T**: Skip backend validation of results

## Additional Resources

- [Socure DocV Documentation](https://developer.socure.com/docs/docv-overview)
- [Socure Dashboard](https://dashboard.socure.com/)
- [Plugin Example App](example/)

## Support

For plugin issues, check the [example app](example/) or create an issue.
For Socure SDK issues, contact [Socure Support](https://support.socure.com).
