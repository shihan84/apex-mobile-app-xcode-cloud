# Apex Prime TV — Flutter Mobile App

A full-featured OTT streaming platform mobile app for **Apex Prime TV** (`apexprimetv.com`), built with Flutter. Supports movies, TV shows, live TV, music streaming, and short-form video reels.

---

## 🚀 Live App

- **Platform**: Android & iOS
- **Backend**: https://apexprimetv.com
- **Admin Panel**: https://apexprimetv.com/admin/login

---

## ✨ Features

### 🎬 Video Streaming
- Movies, TV Shows, Live TV, Videos
- Chromecast support
- Quality selection, subtitles, speed control
- Continue Watching, Watchlist, Reviews & Ratings
- Offline download

### 🎵 Music Player
- Full-screen music player with seek bar
- Persistent mini-player (plays while navigating)
- Background audio with lock screen controls
- Shuffle & Repeat modes, Queue management
- Album detail, Playlist detail screens
- Artist page, Genre browsing
- Global search (tracks, albums, playlists)
- Lyrics tab in player

### 📱 Short Videos (Reels)
- Vertical scroll feed
- Like, Share, Comments

### 🔐 Authentication
- Email/Password login
- Google & Apple Social Login
- Phone OTP Login (Firebase)

### 💳 Monetization
- Subscription Plans (Stripe, Razorpay, Paystack, Flutterwave, PayPal, In-App Purchase)
- Pay-Per-View / Rental
- Google AdMob

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.41.6 |
| State Management | GetX |
| Audio Playback | just_audio + audio_session |
| Image Caching | cached_network_image |
| Auth | Firebase Auth (Google, Apple, Phone OTP) |
| Push Notifications | FCM (Firebase Cloud Messaging) |
| Analytics | Firebase Analytics |
| Video Player | video_player + Chromecast |

---

## 📱 App Info

| | Android | iOS |
|---|---|---|
| Package | `com.apexprime.ott` | `com.apexprime.ott` |
| Min SDK | 21 (Android 5.0) | iOS 15.6 |
| Build | GitHub Actions | Xcode Cloud |

---

## 🔧 Development Setup

### Prerequisites
- Flutter 3.41.6+
- Android Studio / Xcode 15.4+
- Firebase project: `apexprime-ott`

### Install & Run
```bash
flutter pub get
flutter run
```

### Build Android APK/AAB
```bash
# APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

### Build iOS
```bash
flutter build ios --release --no-codesign
```

---

## 🏗 CI/CD

| Platform | Trigger | Output |
|---|---|---|
| **Android** | Push to `android` branch → GitHub Actions | APK + AAB artifacts |
| **iOS** | Push to `android` branch → Xcode Cloud | IPA for TestFlight |

### Android Keystore
- **Alias**: `apexprime`
- **Store password**: `apexprime123`

### Firebase (apexprime-ott)
- **Project ID**: `apexprime-ott`
- **SHA-1 (upload cert)**: `DB:7F:8D:6A:EF:F2:35:D3:BA:5E:6A:B5:BF:AB:46:54:15:D1:7D:2E`

---

## 📂 Project Structure

```
lib/
├── main.dart
├── network/
│   └── core_api.dart          # All API calls
├── utils/
│   └── api_end_points.dart    # API endpoint constants
├── screens/
│   ├── dashboard/             # Bottom nav + MiniPlayer
│   ├── home/                  # Home feed + MusicHomeRow
│   ├── music/                 # Full music module
│   │   ├── services/
│   │   │   └── audio_player_service.dart
│   │   ├── components/
│   │   │   ├── mini_player.dart
│   │   │   └── music_home_row.dart
│   │   ├── music_screen.dart
│   │   ├── music_player_screen.dart
│   │   ├── album_detail_screen.dart
│   │   ├── playlist_detail_screen.dart
│   │   ├── music_search_screen.dart
│   │   ├── genre_browse_screen.dart
│   │   └── artist_tracks_screen.dart
│   ├── auth/
│   │   ├── sign_in/
│   │   └── phone_login_screen.dart
│   └── ...
└── models/
```

---

## 🌐 Backend API

Base URL: `https://apexprimetv.com/api`

| Endpoint | Description |
|---|---|
| `GET /music` | All tracks |
| `GET /music/featured` | Featured tracks |
| `GET /music/albums` | All albums |
| `GET /music/albums/{id}` | Album detail + tracks |
| `GET /music/playlists` | Public playlists |
| `GET /music/playlists/{id}` | Playlist detail + tracks |
| `GET /music/search?q=` | Global music search |
| `GET /music/genre/{genre}` | Tracks by genre |
| `GET /music/artist/{artist}` | Tracks by artist |
| `GET /music/categories` | Music categories |

---

## 🔑 Credentials (Dev)

> Store in `.env` or CI secrets — never commit to repo.

| Service | Value |
|---|---|
| Backend Admin | admin@ApexPrimeTv.com / password |
| Firebase Project | apexprime-ott |
| DB | u894221422_apexprimetv |
