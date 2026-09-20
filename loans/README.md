# loans

## iOS permissions

The plugin cannot add host-app privacy declarations. Apps using Loans KYC must
add these usage descriptions to `ios/Runner/Info.plist`, with copy appropriate
for their KYC experience:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to capture your selfie during KYC.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for audio during video KYC.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required to verify your location during KYC.</string>
```

A new Flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
