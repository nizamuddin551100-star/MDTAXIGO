# MDTaxido - Taxi Meter & Booking App

A Flutter-based taxi meter and booking application for MDTaxido service.

## Features

- 🛺 **Live Fare Meter** - Real-time fare calculation with Day/Night modes
- 📍 **Distance Estimator** - Calculate fares based on route
- 🚕 **Booking System** - Book taxis and auto-rickshaws
- 👨‍💼 **Driver Profile** - Driver info and payment integration
- ⚙️ **Admin Dashboard** - Manage settings (Password: `1234`)

## Installation

### Prerequisites
- Flutter SDK 3.0.0+
- Dart 2.18.0+
- Android SDK (API 21+)

### Build APK

```bash
# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

## Dependencies

- `flutter_map` - Interactive maps
- `latlong2` - Geolocation support
- `geolocator` - GPS tracking
- `share_plus` - Share receipts

## Usage

1. **Meter Page** - Start/end trips with real-time fare calculation
2. **Estimator** - Get fare estimates
3. **Booking** - Book vehicles
4. **Driver** - Driver profile & payments
5. **Admin** - Configure app settings

## Admin Panel

- **Password:** `1234`
- **Features:**
  - Customize theme colors
  - Adjust base fare
  - Set Day/Night rates
  - Custom greetings

## Tech Stack

- **Language:** Dart
- **Framework:** Flutter
- **Maps:** OpenStreetMap (Leaflet)
- **Location:** Geolocator

## License

MIT License
