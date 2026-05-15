#!/bin/sh

set -e

echo "=== Xcode Cloud: ci_post_clone.sh ==="

# Install Flutter SDK
FLUTTER_VERSION="3.41.6"
echo "Installing Flutter $FLUTTER_VERSION..."
cd $HOME
git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter_sdk
export PATH="$PATH:$HOME/flutter_sdk/bin"

echo "Precaching Flutter iOS artifacts..."
flutter precache --ios

echo "Flutter version:"
flutter --version

# Navigate to repository root
cd $CI_PRIMARY_REPOSITORY_PATH

echo "Running flutter pub get..."
flutter pub get

echo "Installing CocoaPods dependencies..."
cd ios
pod install --repo-update

echo "=== ci_post_clone.sh completed successfully ==="
