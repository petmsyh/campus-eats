# Campus Eats - Complete Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Technology Stack](#technology-stack)
4. [Installation Guide](#installation-guide)
5. [API Documentation](#api-documentation)
6. [Database Schema](#database-schema)
7. [User Flows](#user-flows)
8. [Deployment Guide](#deployment-guide)

## Project Overview

Campus Eats is a comprehensive food ordering and lounge management system designed for Ethiopian universities. The platform enables students, teachers, and staff to order food from multiple lounges within their campus using prepaid monthly contracts or direct payment through Chapa.

### Key Features
- Multi-university and multi-campus support
- JWT-based authentication with OTP verification
- Dual payment system (Contract wallet + Chapa)
- QR code-based order verification
- Real-time push notifications
- Commission tracking and reporting
- Role-based access control (User, Lounge, Admin)

## System Architecture

### High-Level Architecture
```
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │
         │ REST API
         │
┌────────▼────────┐      ┌──────────────┐
│  Backend API    │◄────►│   MongoDB    │
│  (Node.js)      │      │   Database   │
└────────┬────────┘      └──────────────┘
         │
         ├──────► Chapa Payment Gateway
         │
         └──────► Firebase Cloud Messaging
```

### Component Breakdown

1. **Backend API (Node.js + Express)**
   - RESTful API endpoints
   - JWT authentication
   - Business logic processing
   - Database operations
   - External service integrations

2. **Mobile App (Flutter)**
   - User interface (Student/Staff)
   - Lounge interface (Restaurant owners)
   - State management with Bloc
   - Local data caching

3. **Database (MongoDB)**
   - User data and authentication
   - Lounge and food menu data
   - Orders and payments
   - Contracts and commissions

4. **External Services**
   - Chapa: Payment processing
   - FCM: Push notifications

## Technology Stack

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js 4.18+
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT + bcryptjs
- **Validation**: express-validator
- **Logging**: Winston
- **Security**: Helmet, CORS, Rate limiting

### Frontend
- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Flutter Bloc
- **HTTP Client**: Dio
- **Local Storage**: Hive + SharedPreferences
- **QR Code**: qr_flutter, qr_code_scanner
- **Notifications**: firebase_messaging

### DevOps
- **Version Control**: Git
- **CI/CD**: GitHub Actions
- **Containerization**: Docker (optional)
- **Hosting**: Any Node.js host (Heroku, AWS, DigitalOcean)

## Installation Guide

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Configure .env with your credentials
# - MONGODB_URI
# - JWT_SECRET
# - CHAPA_SECRET_KEY
# - FCM credentials

# Start development server
npm run dev

# Start production server
npm start
```

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Configure Firebase
# - Add google-services.json (Android)
# - Add GoogleService-Info.plist (iOS)

# Run app
flutter run
```

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

Request:
{
  "name": "John Doe",
  "phone": "+251912345678",
  "password": "password123",
  "universityId": "university_id",
  "campusId": "campus_id"
}

Response:
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "userId": "user_id",
    "phone": "+251912345678"
  }
}
```

#### Login
```http
POST /auth/login

Request:
{
  "phone": "+251912345678",
  "password": "password123"
}

Response:
{
  "success": true,
  "data": {
    "token": "jwt_token",
    "user": { ... }
  }
}
```

### Order Endpoints

#### Create Order
```http
POST /orders
Authorization: Bearer {token}

Request:
{
  "loungeId": "lounge_id",
  "items": [
    {
      "foodId": "food_id",
      "quantity": 2
    }
  ],
  "paymentMethod": "contract",
  "contractId": "contract_id"
}

Response:
{
  "success": true,
  "data": {
    "id": "order_id",
    "qrCode": "CE-order_id-timestamp-random",
    "qrCodeImage": "data:image/png;base64,...",
    "totalPrice": 150.00,
    "status": "pending"
  }
}
```

#### Verify QR Code
```http
POST /orders/verify-qr
Authorization: Bearer {token}

Request:
{
  "qrCode": "CE-order_id-timestamp-random"
}

Response:
{
  "success": true,
  "message": "Order verified and marked as delivered",
  "data": { ... }
}
```

## Database Schema

### User Collection
```javascript
{
  _id: ObjectId,
  name: String,
  phone: String (unique),
  email: String,
  password: String (hashed),
  role: String (enum: user, lounge, admin),
  universityId: ObjectId (ref: University),
  campusId: ObjectId (ref: Campus),
  walletBalance: Number,
  isActive: Boolean,
  isVerified: Boolean,
  otp: {
    code: String,
    expiresAt: Date
  },
  fcmToken: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Order Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User),
  loungeId: ObjectId (ref: Lounge),
  items: [{
    foodId: ObjectId (ref: Food),
    name: String,
    quantity: Number,
    price: Number,
    subtotal: Number
  }],
  totalPrice: Number,
  status: String (enum: pending, preparing, ready, delivered, cancelled),
  paymentMethod: String (enum: contract, chapa),
  qrCode: String (unique),
  qrCodeImage: String,
  commission: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### Contract Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User),
  loungeId: ObjectId (ref: Lounge),
  totalAmount: Number,
  remainingBalance: Number,
  startDate: Date,
  expiresAt: Date,
  isExpired: Boolean,
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

## User Flows

### Order Flow - Contract Payment

1. **Browse Lounges**
   - User opens app
   - View lounges in their campus
   - Select a lounge

2. **Select Food Items**
   - Browse menu
   - Add items to cart
   - Review cart

3. **Payment Selection**
   - Choose "Contract Wallet"
   - System checks balance
   - Deduct amount from contract

4. **Order Creation**
   - Order created
   - QR code generated
   - Notification sent to lounge

5. **Order Preparation**
   - Lounge receives order
   - Updates status to "Preparing"
   - User receives notification

6. **Order Ready**
   - Lounge marks order "Ready"
   - User receives notification
   - User goes to pickup

7. **Order Delivery**
   - User shows QR code
   - Lounge scans QR code
   - Order marked "Delivered"

### Order Flow - Chapa Payment

1-2. Same as Contract Payment

3. **Payment via Chapa**
   - Choose "Pay with Chapa"
   - Redirect to Chapa WebView
   - Complete payment
   - Return to app

4-7. Same as Contract Payment

## Deployment Guide

### Backend Deployment (Heroku Example)

```bash
# Install Heroku CLI
# Login to Heroku
heroku login

# Create app
heroku create campus-eats-api

# Add MongoDB addon
heroku addons:create mongolab

# Set environment variables
heroku config:set JWT_SECRET=your_secret
heroku config:set CHAPA_SECRET_KEY=your_key

# Deploy
git push heroku main

# Open app
heroku open
```

### Mobile App Deployment

#### Android
```bash
# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Upload to Google Play Console
```

#### iOS
```bash
# Build release
flutter build ios --release

# Archive in Xcode
# Upload to App Store Connect
```

### Database Setup

#### MongoDB Atlas
1. Create account at mongodb.com/cloud/atlas
2. Create cluster
3. Create database user
4. Whitelist IP addresses
5. Get connection string
6. Update MONGODB_URI in .env

### Environment Variables

#### Backend (.env)
```env
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your-secret-key
CHAPA_SECRET_KEY=your-chapa-key
FCM_SERVER_KEY=your-fcm-key
```

#### Frontend (env.dart)
```dart
class Environment {
  static const String apiBaseUrl = 'https://api.campuseats.et/api/v1';
  static const String chapaPublicKey = 'your-public-key';
}
```

## Security Considerations

1. **Authentication**
   - JWT tokens with expiration
   - Password hashing with bcrypt
   - OTP verification for registration

2. **API Security**
   - HTTPS only in production
   - Rate limiting
   - Input validation
   - CORS configuration

3. **Payment Security**
   - Webhook verification
   - Transaction logging
   - Secure callback handling

4. **Data Protection**
   - Sensitive data encryption
   - Regular backups
   - Access control

## Testing

### Backend Testing
```bash
cd backend
npm test
npm run test:coverage
```

### Frontend Testing
```bash
cd frontend
flutter test
flutter test --coverage
```

## Monitoring & Maintenance

1. **Logging**
   - Winston for backend logging
   - Log rotation and retention
   - Error tracking

2. **Performance**
   - Database indexing
   - Query optimization
   - Caching strategies

3. **Updates**
   - Regular dependency updates
   - Security patches
   - Feature enhancements

## Support & Documentation

- **API Documentation**: /docs/api
- **User Guide**: /docs/user-guide.pdf
- **Lounge Guide**: /docs/lounge-guide.pdf
- **Admin Guide**: /docs/admin-guide.pdf

## License

MIT License - See LICENSE file for details

## Contact

- Email: support@campuseats.et
- Website: https://campuseats.et
- GitHub: https://github.com/petmsyh/campus_eats

---

**Version**: 2.0.0  
**Last Updated**: December 2024  
**Status**: Production Ready
