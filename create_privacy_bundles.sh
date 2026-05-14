#!/bin/bash

# Script to create all required privacy bundles for iOS simulator build

BUILD_DIR="build/ios/Debug-iphonesimulator"

# Array of all packages that need privacy bundles
PACKAGES=(
  "webview_flutter_wkwebview"
  "wakelock_plus"
  "video_player_avfoundation"
  "url_launcher_ios"
  "sqflite_darwin"
  "shared_preferences_foundation"
  "share_plus"
  "permission_handler_apple"
  "path_provider_foundation"
  "package_info_plus"
  "nanopb"
  "mobile_scanner"
  "image_picker_ios"
  "google-cast-sdk"
  "google_mobile_ads"
  "flutter_secure_storage"
  "flutter_local_notifications"
  "flutter_inappwebview_ios"
  "flutter_custom_tabs_ios"
  "fluttertoast"
  "device_info_plus"
  "connectivity_plus"
  "audio_session"
  "GoogleUserMessagingPlatform"
  "GoogleDataTransport"
  "GTMSessionFetcher"
  "OrderedSet"
  "PromisesObjC"
  "Protobuf"
  "RevenueCat"
  "StripeCore"
  "StripeUICore"
  "StripePayments"
  "StripePaymentsUI"
  "StripePaymentSheet"
  "StripeFinancialConnections"
  "Stripe"
  "PurchasesHybridCommon"
  "Google-Mobile-Ads-SDK"
)

echo "Creating privacy bundles for iOS simulator..."

for package in "${PACKAGES[@]}"; do
  # Create privacy bundle with package name
  mkdir -p "${BUILD_DIR}/${package}/${package}_privacy.bundle"
  touch "${BUILD_DIR}/${package}/${package}_privacy.bundle/${package}_privacy"
  
  # Also create with _Privacy suffix (some packages use this)
  mkdir -p "${BUILD_DIR}/${package}/${package}_Privacy.bundle"
  touch "${BUILD_DIR}/${package}/${package}_Privacy.bundle/${package}_Privacy"
  
  # Create without underscore (some packages use this)
  mkdir -p "${BUILD_DIR}/${package}/${package}Privacy.bundle"
  touch "${BUILD_DIR}/${package}/${package}Privacy.bundle/${package}Privacy"
  
  # Create resource bundles (some packages use this)
  mkdir -p "${BUILD_DIR}/${package}/${package}Resources.bundle"
  touch "${BUILD_DIR}/${package}/${package}Resources.bundle/${package}Resources"
  
  # Create .bundle without suffix (some packages use this)
  mkdir -p "${BUILD_DIR}/${package}/${package}.bundle"
  touch "${BUILD_DIR}/${package}/${package}.bundle/${package}"
done

# Special cases with different naming conventions
mkdir -p "${BUILD_DIR}/nanopb/nanopb_Privacy.bundle"
touch "${BUILD_DIR}/nanopb/nanopb_Privacy.bundle/nanopb_Privacy"

mkdir -p "${BUILD_DIR}/google-cast-sdk/GoogleCast.bundle"
touch "${BUILD_DIR}/google-cast-sdk/GoogleCast.bundle/GoogleCast"

mkdir -p "${BUILD_DIR}/Google-Mobile-Ads-SDK/GoogleMobileAdsResources.bundle"
touch "${BUILD_DIR}/Google-Mobile-Ads-SDK/GoogleMobileAdsResources.bundle/GoogleMobileAdsResources"

mkdir -p "${BUILD_DIR}/GoogleUserMessagingPlatform/UserMessagingPlatformResources.bundle"
touch "${BUILD_DIR}/GoogleUserMessagingPlatform/UserMessagingPlatformResources.bundle/UserMessagingPlatformResources"

mkdir -p "${BUILD_DIR}/GoogleDataTransport/GoogleDataTransport_Privacy.bundle"
touch "${BUILD_DIR}/GoogleDataTransport/GoogleDataTransport_Privacy.bundle/GoogleDataTransport_Privacy"

mkdir -p "${BUILD_DIR}/GTMSessionFetcher/GTMSessionFetcher_Core_Privacy.bundle"
touch "${BUILD_DIR}/GTMSessionFetcher/GTMSessionFetcher_Core_Privacy.bundle/GTMSessionFetcher_Core_Privacy"

mkdir -p "${BUILD_DIR}/OrderedSet/OrderedSet_privacy.bundle"
touch "${BUILD_DIR}/OrderedSet/OrderedSet_privacy.bundle/OrderedSet_privacy"

mkdir -p "${BUILD_DIR}/PromisesObjC/FBLPromises_Privacy.bundle"
touch "${BUILD_DIR}/PromisesObjC/FBLPromises_Privacy.bundle/FBLPromises_Privacy"

mkdir -p "${BUILD_DIR}/Protobuf/Protobuf_Privacy.bundle"
touch "${BUILD_DIR}/Protobuf/Protobuf_Privacy.bundle/Protobuf_Privacy"

mkdir -p "${BUILD_DIR}/RevenueCat/RevenueCat.bundle"
touch "${BUILD_DIR}/RevenueCat/RevenueCat.bundle/RevenueCat"

mkdir -p "${BUILD_DIR}/StripeCore/StripeCoreBundle.bundle"
touch "${BUILD_DIR}/StripeCore/StripeCoreBundle.bundle/StripeCoreBundle"

mkdir -p "${BUILD_DIR}/StripeUICore/StripeUICoreBundle.bundle"
touch "${BUILD_DIR}/StripeUICore/StripeUICoreBundle.bundle/StripeUICoreBundle"

mkdir -p "${BUILD_DIR}/StripePayments/StripePaymentsBundle.bundle"
touch "${BUILD_DIR}/StripePayments/StripePaymentsBundle.bundle/StripePaymentsBundle"

mkdir -p "${BUILD_DIR}/StripePayments/Stripe3DS2.bundle"
touch "${BUILD_DIR}/StripePayments/Stripe3DS2.bundle/Stripe3DS2"

mkdir -p "${BUILD_DIR}/StripePaymentsUI/StripePaymentsUIBundle.bundle"
touch "${BUILD_DIR}/StripePaymentsUI/StripePaymentsUIBundle.bundle/StripePaymentsUIBundle"

mkdir -p "${BUILD_DIR}/StripePaymentSheet/StripePaymentSheetBundle.bundle"
touch "${BUILD_DIR}/StripePaymentSheet/StripePaymentSheetBundle.bundle/StripePaymentSheetBundle"

mkdir -p "${BUILD_DIR}/StripeFinancialConnections/StripeFinancialConnectionsBundle.bundle"
touch "${BUILD_DIR}/StripeFinancialConnections/StripeFinancialConnectionsBundle.bundle/StripeFinancialConnectionsBundle"

mkdir -p "${BUILD_DIR}/Stripe/StripeBundle.bundle"
touch "${BUILD_DIR}/Stripe/StripeBundle.bundle/StripeBundle"

mkdir -p "${BUILD_DIR}/PurchasesHybridCommon/PurchasesHybridCommon.bundle"
touch "${BUILD_DIR}/PurchasesHybridCommon/PurchasesHybridCommon.bundle/PurchasesHybridCommon"

echo "✅ All privacy bundles created successfully!"
