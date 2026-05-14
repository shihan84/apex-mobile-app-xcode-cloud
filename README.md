# Streamit - Laravel Flutter Platform

## About The Project
Streamit is a powerful video streaming application built with Flutter, designed to offer a seamless and immersive entertainment experience. It supports movies, TV shows, and videos with a rich set of features including casting, downloading, and multiple payment gateways.

## Features
- **Cross-Platform**: Supports Android, iOS, Web, Windows, macOS, and Linux.
- **Localization**: Full multi-language support including English, French, German, Arabic, Greek, and more.
- **Dynamic Content**: Movies, TV Shows, Videos, and Live TV.
- **User Engagement**: Reviews, Ratings, Watchlist, and Continue Watching.
- **Monetization**:
    - Subscription Plans (In-App Purchases, Stripe, Razorpay, Paystack, Flutterwave, Paypal, etc.)
    - Pay-Per-View / Rental
    - Advertisement Support (Google AdMob)
- **Playback**:
    - Casting support (Chromecast)
    - Video Player with quality selection, subtitles, and speed control.
- **Offline Viewing**: Download content for offline access.
- **Authentication**: Social Login (Google, Apple), OTP Verification.

## Development Environment

### 🐦 Flutter

- **Version**: 3.38.0
- **Framework Revision**: a0e9b9dbf7 (2025-11-11)
- **DevTools**: 2.51.1
- **Supported Platforms**: Android, iOS, Web, Windows, macOS, Linux

### 📱 Android

- **Android SDK**: 36.1.0-rc1
- **Build-tools**: 36.0.0
- **Emulator**: 36.1.9.0
- **Java (configured for Flutter)**: 17.0.15+6-LTS
- **Java (from Android Studio)**: OpenJDK 21.0.7

### 💻 IDEs

- **Android Studio**: 2025.1.3
    - Plugins: Flutter, Dart
- **Visual Studio Code**: 1.102.3
    - Extension: Flutter

### 🖥️ OS

- **Windows 11 (24H2, build 2009)**

## Configuration Guide

To customize the application for your environment, please follow these configuration steps:

### 1. Domain & API Configuration
- Open `lib/configs.dart`.
- Update `DOMAIN_URL` with your backend domain (e.g., `https://your-domain.com`).
- `BASE_URL` is automatically derived from `DOMAIN_URL`.

### 2. Payment Gateways
- **Stripe**: In `lib/configs.dart`, update `STRIPE_merchantIdentifier`, `STRIPE_MERCHANT_COUNTRY_CODE`, and `STRIPE_CURRENCY_CODE`.
- **RazorPay, PayStack, PayPal**: Check `lib/configs.dart` for relevant currency and key configurations.

### 3. Google Ads
- **Configuration**: Open `lib/configs.dart` and update the Ad Unit IDs for Android and iOS (Interstitial, Banner).
- **Manifest/Info.plist**:
    - **Android**: Update `com.google.android.gms.ads.APPLICATION_ID` in `android/app/src/main/AndroidManifest.xml`.
    - **iOS**: Update `GADApplicationIdentifier` in `ios/Runner/Info.plist`.

### 4. Firebase Configuration
- **Setup**: Create a new project in the [Firebase Console](https://console.firebase.google.com/).
- **Android**: Download `google-services.json` and place it in `android/app/`.
- **iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
- **Dart Config**: Run `flutterfire configure` or manually update `lib/firebase_options.dart` with your new project keys (API Key, App ID, Messaging Sender ID, Project ID).
- **Auth**: Update `FIREBASE_SERVER_CLIENT_ID` in `lib/configs.dart`.

### 5. Push Notifications
- Ensure Firebase Messaging is set up correctly as per step 4.
- Logic is handled in `lib/services/push_notification_service.dart`.
- **Topic Subscription**: The app subscribes to an app-wide topic `streamit_laravel` and user-specific topics.
- **Notification Icon**: Ensure you have generated a notification icon named `ic_stat_ic_notification` and placed it in the `android/app/src/main/res/drawable` folders. This is required for the status bar icon to display correctly on Android.

### 6. Platform Specifics
- **Android**:
    - Check `android/app/src/main/AndroidManifest.xml` to update `package` name if you refactor.
    - Verify required permissions (Internet, Camera, Storage, etc.).
- **iOS**:
    - Check `ios/Runner/Info.plist` to update `CFBundleIdentifier` (Bundle ID).
    - Verify privacy descriptions (Camera, Photo Library, Microphone usage).

## Postman Collection

A Postman collection is included to help you test and understand the API endpoints used by the application.

- **Location**: The collection files are located in the `postman/` directory at the root of the project.
- **Usage**:
    1. Open [Postman](https://www.postman.com/).
    2. Click on **Import**.
    3. Drag and drop the files from the `postman/` folder into Postman or select the folder.
    4. You will see a new collection named **Streamit** (or similar) with organized folders for different modules (Auth, Dashboard, Content, etc.).
    5. Configure the environment variables (like `base_url`, `api_token`) in Postman to match your local or staging server.
