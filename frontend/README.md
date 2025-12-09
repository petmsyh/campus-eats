# Campus Eats - Mobile App

Ethiopian Universities Food Ordering & Lounge Management System - Flutter Mobile Application

## 📱 Overview

This is the mobile application for Campus Eats, built with Flutter. It provides both user-facing and lounge-facing interfaces for the complete food ordering experience.

## 🎯 Features

### User Features
- **Authentication**: Phone-based registration with OTP verification
- **Browse Lounges**: View all lounges in your campus
- **Menu Browsing**: Explore food items with categories and filters
- **Shopping Cart**: Add items to cart with quantity selection
- **Dual Payment**: Pay using contract wallet or Chapa direct payment
- **QR Code**: Receive QR code for order pickup verification
- **Order Tracking**: Real-time order status updates
- **Push Notifications**: Receive notifications for order updates
- **Wallet Management**: View and manage contract balance
- **Order History**: View past orders and reorder

### Lounge Features
- **Order Management**: Receive and manage orders
- **QR Scanner**: Scan customer QR codes for verification
- **Menu Management**: Add, edit, and manage food items
- **Order Status Updates**: Update order status (preparing, ready, delivered)
- **Dashboard**: View sales and order analytics

## 🛠️ Tech Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Flutter Bloc
- **HTTP Client**: Dio
- **Local Storage**: Hive + SharedPreferences
- **QR Code**: qr_flutter + qr_code_scanner
- **Notifications**: Firebase Cloud Messaging
- **Payment**: WebView Flutter (Chapa integration)

## 📦 Installation

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode
- Firebase account for FCM

### Setup Steps

1. **Clone the repository**
   ```bash
   cd campus_eats/frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Firebase**
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)
   - Place them in respective platform directories

5. **Run the app**
   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

## 🔧 Configuration

### Environment Variables

Create `lib/config/env.dart`:

```dart
class Environment {
  static const String apiBaseUrl = 'https://your-api-url.com/api/v1';
  static const String chapaPublicKey = 'your-chapa-public-key';
}
```

### Firebase Setup

1. Create Firebase project
2. Add Android and iOS apps
3. Download configuration files
4. Enable Cloud Messaging
5. Add server key to backend

## 📂 Project Structure

```
frontend/
├── lib/
│   ├── models/              # Data models
│   │   ├── user.dart
│   │   ├── lounge.dart
│   │   ├── food.dart
│   │   ├── order.dart
│   │   └── contract.dart
│   ├── screens/             # UI screens
│   │   ├── auth/
│   │   ├── home/
│   │   ├── menu/
│   │   ├── cart/
│   │   ├── orders/
│   │   └── profile/
│   ├── widgets/             # Reusable widgets
│   │   ├── buttons/
│   │   ├── cards/
│   │   └── dialogs/
│   ├── services/            # API services
│   │   ├── api_client.dart
│   │   ├── auth_service.dart
│   │   ├── order_service.dart
│   │   └── payment_service.dart
│   ├── bloc/                # State management
│   │   ├── auth/
│   │   ├── orders/
│   │   └── cart/
│   ├── utils/               # Utility functions
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── constants.dart
│   ├── config/              # Configuration
│   │   ├── app_config.dart
│   │   ├── app_theme.dart
│   │   └── routes.dart
│   └── main.dart            # Entry point
├── assets/                  # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/                    # Tests
├── android/                 # Android configuration
├── ios/                     # iOS configuration
└── pubspec.yaml            # Dependencies
```

## 🎨 Screens

### Authentication Flow
1. **Splash Screen** - App initialization
2. **Onboarding** - First-time user guide
3. **Login/Register** - Phone-based authentication
4. **OTP Verification** - Verify phone number

### User Flow
1. **Home** - Browse lounges in campus
2. **Lounge Details** - View lounge info and menu
3. **Food Details** - Detailed food information
4. **Cart** - Review items and proceed to payment
5. **Payment** - Choose contract or Chapa payment
6. **Order Confirmation** - QR code and order details
7. **Order Tracking** - Real-time status updates
8. **Profile** - User info, wallet, contracts

### Lounge Flow
1. **Dashboard** - Orders overview and stats
2. **Orders List** - All orders with filters
3. **Order Details** - Full order information
4. **QR Scanner** - Scan for order verification
5. **Menu Management** - Add/edit food items

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📱 Build & Release

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## 🔐 Security

- Secure token storage using Flutter Secure Storage
- HTTPS-only API communication
- Certificate pinning for API requests
- Input validation and sanitization
- Secure payment handling via Chapa

## 🚀 Performance

- Image caching with cached_network_image
- Lazy loading for lists
- Optimized build methods
- Shimmer loading effects
- Offline data caching with Hive

## 📊 State Management

Using **Flutter Bloc** pattern:

```dart
// Example Bloc structure
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  // Events: CreateOrder, UpdateOrder, LoadOrders
  // States: OrderInitial, OrderLoading, OrderLoaded, OrderError
}
```

## 🔔 Push Notifications

Firebase Cloud Messaging for:
- Order status updates
- Low wallet balance alerts
- Contract expiry reminders
- Promotional notifications

## 💳 Payment Integration

Chapa payment via WebView:
1. Initialize payment on backend
2. Load Chapa checkout URL in WebView
3. Handle payment callback
4. Verify payment status
5. Complete order

## 🎯 Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  dio: ^5.4.0                    # HTTP client
  hive: ^2.2.3                   # Local database
  qr_flutter: ^4.1.0             # QR code display
  qr_code_scanner: ^1.0.1        # QR code scanning
  firebase_messaging: ^14.7.9    # Push notifications
  cached_network_image: ^3.3.0   # Image caching
  webview_flutter: ^4.4.2        # Payment WebView
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Write tests for new features
4. Ensure all tests pass
5. Submit pull request

## 📄 License

MIT License - See LICENSE file

## 👥 Support

For support, email support@campuseats.et

## 🔄 Version

Current Version: **2.0.0**

---

Made with ❤️ using Flutter
