# Ad Integration Roadmap

This document captures the findings and planned future work for adding ad support across the app.

## 1. Live TV Ad Support

### Current state
- Live TV routes to the shared `VideoScreen`, which already contains the `AdManager` and supports pre-roll, mid-roll, post-roll, and overlay ads.
- The app currently does **not** parse ad data for live TV content, so `isAdsAvailable` stays `false` and no ads are shown.

### Required changes

#### Backend
- File: `backend/Modules/LiveTV/Transformers/LiveTvChannelDetailsResourceV3.php`
- Add an `ads_data` block to the response and fetch active custom ads / VAST URLs for a `live_tv` placement.

Example response addition:
```php
'ads_data' => [
    'custom_ads' => $customAds->toArray(),
    'vast_ads'   => $vastAds,
],
```

#### Mobile app
- File: `mobile-app/lib/screens/content/model/content_model.dart`
- Update `ContentModel.fromLiveContentJson` to parse `ads_data`:

```dart
adsData: json['ads_data'] is Map ? AdsData.fromJson(json['ads_data']) : null,
```

### Important considerations for live TV
- **Pre-roll** ads work well before the stream starts.
- **Mid-roll / post-roll** ads are not suitable for live streams because there is no fixed duration or playback end.
- **Overlay ads** can be shown, but they should not pause the live stream. Consider non-blocking banner overlays only.
- Recommended first implementation: **pre-roll only** for live TV.

---

## 2. App-Open Custom Ad (Option A)

### Goal
Show a custom image or video ad on the splash screen before navigating to the home dashboard or walkthrough screens.

### Current state
- The splash screen (`lib/screens/splash_screen.dart`) only displays a loader and immediately navigates.
- Custom ads are supported via `CustomAdsSetting` with placements, but there is no `app_open` placement.

### Required changes

#### Backend
- Extend `CustomAdsSetting` / `Modules\Ad\Models\CustomAdsSetting` to support a new `placement` value: `app_open`.
- Provide an admin UI to create an app-open ad with:
  - Type: `image` or `video`
  - Media file / URL
  - Redirect URL
  - Start date / end date
  - Status
- Expose the active `app_open` ad via the existing app-configuration API or a new dedicated endpoint.

#### Mobile app
- File: `mobile-app/lib/screens/splash_controller.dart`
- After `getAppConfigurations()`, fetch the active `app_open` ad from the config response.
- If an active ad exists, show a full-screen ad widget with:
  - Countdown timer
  - Skip button (optional, after N seconds)
  - Tap-to-open redirect URL
- After the ad finishes or is skipped, navigate to dashboard / walkthrough.

### Suggested UI flow
1. App launches → splash loader.
2. Config loads → check for `app_open` ad.
3. If ad exists:
   - Show `AppOpenAdScreen` (image or video).
   - Auto-dismiss after duration or on skip.
4. Navigate to the next screen (walkthrough or dashboard).

### Files likely to be created or modified
- `mobile-app/lib/screens/splash/app_open_ad_screen.dart` (new)
- `mobile-app/lib/screens/splash/splash_controller.dart`
- `mobile-app/lib/screens/auth/model/app_configuration_res.dart` (add app-open ad fields)
- `backend/app/Http/Controllers/Backend/API/SettingController.php` (return app-open ad)
- `backend/Modules/Ad/Models/CustomAdsSetting.php` (if placement enum needs update)

---

## 3. Short-Term vs Long-Term

| Feature | Effort | Recommended priority |
|---|---|---|
| Live TV pre-roll ads | Medium | High — backend + one-line app change |
| App-open custom ad | Medium-High | Medium — requires new UI and placement support |
| Music / Shorts ads | High | Low — players are separate from `VideoScreen` and need major rework |

---

## 4. Current Homepage Banner Ad / Rate Tab Issue

### Current state
- The bottom banner ad (`AdComponent`) and the rate-our-app section (`RateComponent`) are still present in the home screen code.
- They are only inserted when the app config flags are enabled:
  - Banner ad: `appConfigs.value.enableAds.getBoolInt()` is `true`
  - Rate tab: `appConfigs.value.enableRateUs` is `true`
- These flags come from backend `app-configuration-v3`:
  - `enable_ads` = `MobileSetting` row with slug `banner`
  - `enable_rate_us` = `MobileSetting` row with slug `rate-our-app`

### Why they disappeared in the new build
Most likely the backend `MobileSetting` rows for `banner` and/or `rate-our-app` are set to `0` (disabled) or not present.

### How to restore them
1. Log in to admin panel.
2. Go to **Mobile App Settings** (or wherever `MobileSetting` slugs are managed).
3. Ensure these settings are enabled:
   - slug: `banner` → value `1`
   - slug: `rate-our-app` → value `1`
4. Re-launch the app. The banner will show real AdMob ads in release builds; the "Test Ad" label only appears in debug/test builds.

### Note about "Test Ad" label
- The "Test Ad" label is shown by AdMob only when the banner loads a **test ad unit ID** (debug builds).
- In a release/production build, the label disappears and real ads are shown if valid AdMob IDs are configured.
- If real ads do not load, the banner area collapses to zero height and nothing is shown.

---

## 5. Play Store 16 KB Device Warning (Fixed)

### Warning
```
base/lib/arm64-v8a/libdatastore_shared_counter.so
base/lib/x86_64/libdatastore_shared_counter.so
```

### Applied fix
- `@/Users/macair/development/apexT/production/mobile-app/android/app/build.gradle`
  - Added explicit 16 KB-aligned `androidx.datastore` dependencies (version `1.1.6`).
  - Set `packagingOptions.jniLibs.useLegacyPackaging = false` to ensure native libraries are loaded directly from the APK with correct page alignment.

### Verification
- After the next Android build, re-upload the AAB to Play Console and check that the 16 KB warning is gone.
- If the warning persists, also run `flutter pub upgrade shared_preferences` to pull the latest compatible Android implementation.

---

## Notes
- Do not implement these changes during the current App Store rejection resolution cycle unless necessary.
- Both features should be built on a dedicated feature branch and tested before merging to `android` / `main`.
