# Ad Integration Roadmap

This document captures the findings and planned future work for adding ad support across the app.

## 1. Live TV Ad Support — IMPLEMENTED

### What changed
- Backend now fetches active VAST ads for `target_type = 'livetv'` in `backend/Modules/LiveTV/Http/Controllers/API/LiveTVsController.php`.
- Backend returns an `ads_data` block from `LiveTvChannelDetailsResourceV3`.
- Mobile app parses `ads_data` in `ContentModel.fromLiveContentJson` so the shared `VideoScreen` can play pre-roll ads before a live TV stream starts.

### Admin setup
1. Go to **VAST Ads** in the admin panel.
2. Create a VAST ad with:
   - **Type:** `pre-roll`
   - **Target type:** `Live TV`
   - **Target selection:** choose the channel(s)
   - Active status and valid start/end dates
3. Open the channel in the app. A pre-roll ad will play before the stream.

### Important considerations for live TV
- **Pre-roll** ads work well before the stream starts.
- **Mid-roll / post-roll** ads are not suitable for live streams because there is no fixed duration or playback end.
- **Overlay ads** can be shown, but they should not pause the live stream.

---

## 2. App-Open Custom Ad (Option A) — IMPLEMENTED

### What changed
- Added `app_open` placement to `CustomAdsSetting`.
- Backend returns the active `app_open_ad` in both `app-configuration` and `app-configuration-v3` responses.
- Mobile app parses `app_open_ad` in `ConfigurationResponse` and shows a full-screen `AppOpenAdScreen` on the splash flow.
- Supports image or video ads, optional skip timer, duration timer, and redirect URL tap.

### Admin setup
1. Go to **Custom Ads** in the admin panel.
2. Create a custom ad with:
   - **Placement:** `App Open`
   - **Type:** `image` or `video`
   - Media file / URL
   - Redirect URL (optional)
   - Duration (seconds) and skip settings
   - Active status and valid start/end dates
3. On next app launch, the ad will display before the home/walkthrough screen.

### Files changed
- `mobile-app/lib/screens/splash/app_open_ad_screen.dart` (new)
- `mobile-app/lib/screens/splash/splash_controller.dart`
- `mobile-app/lib/screens/auth/model/app_configuration_res.dart`
- `backend/app/Http/Controllers/Backend/API/SettingController.php`
- `backend/Modules/Ad/Resources/views/backend/customads/create.blade.php`
- `backend/Modules/Ad/Resources/views/backend/customads/edit.blade.php`
- `backend/Modules/Ad/Resources/views/backend/customads/index.blade.php`

---

## 3. Short-Term vs Long-Term

| Feature | Effort | Status | Recommended priority |
|---|---|---|---|
| Live TV pre-roll ads | Medium | Implemented | High — backend + one-line app change |
| App-open custom ad | Medium-High | Implemented | Medium — requires new UI and placement support |
| Music / Shorts ads | High | Not started | Low — players are separate from `VideoScreen` and need major rework |

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
