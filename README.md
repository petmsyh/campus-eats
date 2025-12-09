# Campus Eats 🍽️

Ethiopian Universities Food Ordering & Lounge Management System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)

## 📖 Overview

Campus Eats is a comprehensive food ordering and lounge management system designed specifically for Ethiopian universities. The platform enables students, teachers, and staff to order food from multiple lounges within their campus, using either prepaid monthly contracts or direct payment through Chapa.

### Key Features

- 🔐 **Secure Authentication** - JWT-based auth with OTP verification
- 🏫 **Multi-University Support** - Designed for multiple universities and campuses
- 🍕 **Food Ordering** - Complete order lifecycle from cart to delivery
- 💳 **Flexible Payment** - Contract wallet or direct Chapa payment
- 📱 **QR Code Verification** - Secure order pickup verification
- 🔔 **Real-time Notifications** - FCM push notifications for order updates
- 📊 **Admin Dashboard** - Comprehensive analytics and management
- 💰 **Commission System** - Automated commission tracking and reporting

## 🏗️ Architecture

The system consists of three main components:

1. **Backend API** (Node.js + Express + MongoDB)
   - RESTful API server
   - Authentication & authorization
   - Payment processing
   - QR code generation
   - Push notifications

2. **Mobile App** (Flutter)
   - User interface for students/staff
   - Lounge interface for restaurant owners
   - Order management
   - QR code scanning

3. **Admin Panel** (Web)
   - User management
   - Lounge approval
   - Revenue reports
   - System configuration

## 🚀 Getting Started

### Prerequisites

- Node.js v18 or higher
- MongoDB
- Flutter SDK 3.0+
- Chapa account for payments
- Firebase project for FCM

### Quick Start

#### Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Configure your .env file
npm run dev
```

See [Backend README](./backend/README.md) for detailed instructions.

#### Mobile App Setup

```bash
cd frontend
flutter pub get
flutter run
```

See [Frontend README](./frontend/README.md) for detailed instructions.

## 📱 User Roles

### 1. Users (Students/Staff/Teachers)
- Register and verify account
- Browse lounges in their campus
- Order food using contract or Chapa
- Track order status
- Receive QR code for pickup
- Manage wallet balance

### 2. Lounge Owners
- Register lounge with university
- Manage food menu
- Receive and process orders
- Scan QR codes for verification
- Update order status
- View sales reports

### 3. System Admins
- Manage universities and campuses
- Approve/reject lounge registrations
- View system analytics
- Manage users
- Track commissions and revenue

## 🔄 Order Workflow

### Contract-Based Order
1. User selects food items
2. System validates contract balance
3. Balance deducted and order created
4. QR code generated
5. Lounge receives notification
6. Lounge prepares food and marks ready
7. User receives notification
8. User shows QR code for pickup
9. Lounge scans QR and marks delivered

### Direct Payment Order
1. User selects food items
2. Payment via Chapa WebView
3. Backend confirms payment
4. Order created with QR code
5. (Same as steps 5-9 above)

## 💳 Payment System

### Chapa Integration
- Direct payment gateway integration
- WebView checkout experience
- Webhook for payment confirmation
- Automatic order activation

### Contract Wallet
- Prepaid monthly contracts per lounge
- Automatic balance deduction
- Low balance notifications
- Easy renewal system

## 📊 Commission System

- Configurable commission rate (default 5%)
- Automatic calculation per order
- Commission tracking and reporting
- Payment status management

## 🔒 Security Features

- JWT authentication with refresh tokens
- Password hashing with bcrypt
- OTP verification for registration
- Role-based access control (RBAC)
- Rate limiting
- Input validation
- Secure payment callbacks
- QR code encryption

## 🛠️ Technology Stack

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB + Mongoose
- **Authentication**: JWT + bcryptjs
- **Payment**: Chapa API
- **Notifications**: Firebase FCM
- **QR Codes**: qrcode library
- **Logging**: Winston

### Frontend
- **Framework**: Flutter
- **State Management**: Bloc/Riverpod
- **HTTP Client**: Dio
- **Local Storage**: Hive/SharedPreferences
- **QR Scanner**: qr_code_scanner
- **Notifications**: firebase_messaging

## 📂 Project Structure

```
campus_eats/
├── backend/              # Node.js REST API
│   ├── src/
│   │   ├── models/      # Database models
│   │   ├── routes/      # API routes
│   │   ├── middleware/  # Express middleware
│   │   ├── services/    # External services
│   │   ├── utils/       # Utility functions
│   │   └── server.js    # Entry point
│   └── package.json
├── frontend/            # Flutter mobile app
│   ├── lib/
│   │   ├── models/      # Data models
│   │   ├── screens/     # UI screens
│   │   ├── widgets/     # Reusable widgets
│   │   ├── services/    # API services
│   │   ├── bloc/        # State management
│   │   └── main.dart    # Entry point
│   └── pubspec.yaml
├── docs/                # Documentation
└── README.md
```

## 📝 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/verify-otp` - Verify OTP

### Orders
- `POST /api/v1/orders` - Create order
- `GET /api/v1/orders` - Get orders
- `PUT /api/v1/orders/:id/status` - Update status
- `POST /api/v1/orders/verify-qr` - Verify QR code

### Payments
- `POST /api/v1/payments/initialize` - Initialize payment
- `POST /api/v1/payments/webhook` - Payment webhook

[Complete API documentation](./docs/API.md)

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
flutter test
```

## 🚢 Deployment

### Backend Deployment
- Deploy to Heroku, AWS, DigitalOcean, or any Node.js host
- Set up MongoDB Atlas for database
- Configure environment variables
- Set up Chapa webhook URL

### Mobile App Deployment
- Build APK for Android: `flutter build apk`
- Build iOS app: `flutter build ios`
- Deploy to Google Play Store / Apple App Store

## 📈 Performance

- API response time: < 1 second
- Supports up to 50,000 daily users per university
- Horizontal scaling ready
- Offline sync support

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 👥 Authors

- Campus Eats Team

## 🙏 Acknowledgments

- Ethiopian Universities for the inspiration
- Chapa for payment gateway support
- Firebase for notification services

## 📞 Contact

- Email: support@campuseats.et
- Website: https://campuseats.et
- Telegram: @campuseats

## 🗺️ Roadmap

- [x] Backend API implementation
- [ ] Flutter mobile app
- [ ] Admin web panel
- [ ] SMS notifications
- [ ] Rating and review system
- [ ] Analytics dashboard
- [ ] Multiple payment methods
- [ ] Loyalty program

## 📊 Status

Current Version: **2.0.0**

Status: **In Development** 🚧

---

Made with ❤️ in Ethiopia
