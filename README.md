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

1. **Backend API** (Node.js + Express + PostgreSQL)
   - RESTful API server
   - Authentication & authorization with JWT
   - Payment processing via Chapa
   - QR code generation for order verification
   - Push notifications via Firebase FCM
   - PostgreSQL database with Prisma ORM

2. **Mobile App** (Flutter)
   - User interface for students/staff
   - Lounge interface for restaurant owners
   - Order management
   - QR code scanning
   - Real-time notifications

3. **Admin Panel** (Web)
   - User management
   - Lounge approval
   - Revenue reports
   - System configuration

## 🚀 Getting Started

### Prerequisites

- Node.js v18 or higher
- PostgreSQL 12 or higher
- Flutter SDK 3.0+
- Chapa account for payments
- Firebase project for FCM

### Quick Start

#### Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Configure your .env file with PostgreSQL connection
# DATABASE_URL=postgresql://username:password@localhost:5432/campus_eats

# Development: Create and apply migrations
npm run prisma:migrate

# Generate Prisma Client
npm run prisma:generate

# Start development server
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
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Authentication**: JWT + bcryptjs
- **Payment**: Chapa API
- **Notifications**: Firebase FCM
- **QR Codes**: qrcode library
- **Logging**: Winston
- **Validation**: express-validator

### Frontend
- **Framework**: Flutter
- **State Management**: Bloc/Riverpod
- **HTTP Client**: Dio
- **Local Storage**: Hive/SharedPreferences
- **QR Scanner**: qr_code_scanner
- **Notifications**: firebase_messaging

## 📱 Frontend Activities & Features

### User Interface (Student/Staff/Teacher)

#### 1. Authentication & Onboarding
- **Splash Screen**: App initialization and loading
- **Onboarding**: First-time user tutorial slides
- **Registration**: 
  - Phone number input with country code
  - Personal information (name, email)
  - University and campus selection
  - Password creation
  - OTP verification via SMS
- **Login**: Phone and password authentication
- **Password Recovery**: OTP-based password reset

#### 2. Home & Browse
- **Campus Lounges List**: 
  - View all approved lounges in user's campus
  - Filter by rating, distance, or category
  - Search lounges by name
  - View lounge cards with logo, rating, and opening hours
- **Lounge Details**:
  - View lounge information and operating hours
  - Browse complete food menu
  - View lounge ratings and reviews
  - Check active contract status with lounge

#### 3. Food Menu & Ordering
- **Menu Browsing**:
  - View food items organized by categories (Breakfast, Lunch, Dinner, Snacks, Drinks, Dessert)
  - Filter by dietary preferences (vegetarian, spicy level)
  - Search food items by name
  - View food details (ingredients, allergens, estimated time)
- **Food Details Screen**:
  - High-quality food images
  - Detailed description and pricing
  - Nutritional information
  - Allergen warnings
  - Spicy level indicators
- **Shopping Cart**:
  - Add/remove items with quantity selector
  - View cart summary with itemized pricing
  - Apply discount codes (if available)
  - See estimated preparation time
  - Modify quantities before checkout

#### 4. Payment & Checkout
- **Payment Method Selection**:
  - **Contract Wallet**: Use prepaid monthly contract
    - View remaining balance
    - Low balance warning
    - Option to renew contract
  - **Direct Payment**: Pay via Chapa gateway
    - Credit/Debit card
    - Mobile money integration
- **Contract Management**:
  - Create new contract with lounge
  - Choose contract amount and duration
  - View contract history
  - Renew expiring contracts
- **Chapa Payment Flow**:
  - Initialize payment on backend
  - Load Chapa checkout in WebView
  - Complete payment securely
  - Automatic order confirmation on success

#### 5. Order Management
- **Order Confirmation**:
  - QR code generation for pickup
  - Order summary with items and total
  - Estimated ready time
  - Lounge contact information
- **Order Tracking**:
  - Real-time order status updates
  - Status stages: Pending → Preparing → Ready → Delivered
  - Push notifications for each status change
  - Estimated completion countdown
- **QR Code Display**:
  - Full-screen QR code for easy scanning
  - Order details overlay
  - Share QR code option
- **Order History**:
  - View past orders with filters
  - Reorder previous items with one tap
  - View detailed receipts
  - Track delivery status

#### 6. Profile & Account
- **User Profile**:
  - Edit personal information
  - Change password
  - Update phone number
  - Manage notification preferences
- **Wallet Management**:
  - View wallet balance
  - View all active contracts
  - Contract expiry dates
  - Payment history
- **Order History**: Complete order archive
- **Settings**:
  - Language preferences
  - Notification settings
  - Theme (light/dark mode)
  - Privacy settings
  - App version and updates

#### 7. Notifications
- **Push Notifications**:
  - Order status updates (preparing, ready, delivered)
  - Contract expiry reminders
  - Low balance alerts
  - Promotional offers from lounges
  - New menu items
- **In-App Notifications**:
  - Notification center with history
  - Mark as read/unread
  - Clear all notifications

### Lounge Owner Interface

#### 1. Dashboard
- **Overview Statistics**:
  - Today's orders count
  - Total revenue (daily, weekly, monthly)
  - Active orders requiring attention
  - Pending orders count
  - Average preparation time
- **Quick Actions**:
  - View new orders
  - Scan QR code
  - Manage menu
  - View reports

#### 2. Order Management
- **Orders List**:
  - View all orders with status filters
  - Real-time order notifications
  - Order priority indicators
  - Filter by date range, status, payment method
- **Order Details**:
  - Customer information (name, phone)
  - Complete order items list
  - Payment method and status
  - Order timestamps
  - Special instructions/notes
- **Order Status Updates**:
  - Mark as "Preparing" when starting
  - Mark as "Ready" when complete
  - Update estimated ready time
  - Cancel orders with reason
- **Order History**: Complete archive with search

#### 3. QR Code Verification
- **QR Scanner**:
  - Built-in camera scanner
  - Automatic QR code detection
  - Verify order authenticity
  - Mark order as delivered automatically
  - Error handling for invalid codes
- **Manual Verification**:
  - Enter order ID manually
  - Verify customer details
  - Confirm pickup

#### 4. Menu Management
- **Food Items List**:
  - View all menu items
  - Quick enable/disable availability toggle
  - Category-wise organization
  - Search and filter options
- **Add New Food Item**:
  - Upload food image
  - Enter name, description, and price
  - Select category and spicy level
  - Add ingredients and allergen information
  - Set estimated preparation time
  - Mark as vegetarian if applicable
- **Edit Food Items**:
  - Update pricing
  - Modify descriptions
  - Change availability status
  - Update images
- **Delete Items**: Remove discontinued items

#### 5. Lounge Profile Management
- **Business Information**:
  - Update lounge name and description
  - Change logo/cover image
  - Edit operating hours
  - Update contact information
- **Bank Account Details**:
  - Update payment account information
  - Manage commission settings
- **Settings**:
  - Auto-accept orders toggle
  - Notification preferences
  - Busy mode (temporarily pause orders)

#### 6. Reports & Analytics
- **Sales Reports**:
  - Daily/weekly/monthly revenue
  - Order count statistics
  - Popular menu items
  - Peak order times
- **Commission Tracking**:
  - View commission calculations
  - Pending vs paid commissions
  - Commission history
- **Customer Insights**:
  - Repeat customer statistics
  - Average order value
  - Customer feedback and ratings

### Technical Implementation Details

#### State Management Architecture
- **BLoC Pattern** (Business Logic Component):
  - Separates business logic from UI
  - Event-driven architecture
  - Reactive state updates
  - Easy testing and debugging

**Key BLoCs**:
- `AuthBloc`: Handles authentication state
- `OrderBloc`: Manages order creation and tracking
- `CartBloc`: Shopping cart state management
- `PaymentBloc`: Payment flow management
- `NotificationBloc`: Notification handling
- `ProfileBloc`: User profile management

#### Services Layer
- **API Client Service**:
  - HTTP requests using Dio
  - Automatic token injection
  - Request/response interceptors
  - Error handling and retry logic
- **Authentication Service**:
  - Token management
  - Auto-refresh tokens
  - Secure storage
- **Order Service**: Order CRUD operations
- **Payment Service**: Chapa integration
- **Notification Service**: FCM handling
- **Storage Service**: Local data persistence

#### Local Storage
- **Hive Database**:
  - Offline order caching
  - User preferences
  - Cart persistence
- **Shared Preferences**:
  - App settings
  - Theme preferences
  - First-time user flags
- **Secure Storage**:
  - Authentication tokens
  - Sensitive user data

#### Navigation
- **Named Routes**:
  - Clean navigation structure
  - Deep linking support
  - Route guards for authentication
- **Bottom Navigation**: Main app sections
- **Drawer Navigation**: Settings and profile access

#### UI/UX Features
- **Responsive Design**: Adapts to different screen sizes
- **Dark Mode Support**: System-based or manual toggle
- **Shimmer Loading**: Skeleton screens during data fetch
- **Pull-to-Refresh**: Update data manually
- **Infinite Scroll**: Lazy loading for lists
- **Cached Images**: Fast image loading with caching
- **Offline Support**: View cached data when offline
- **Error Handling**: User-friendly error messages
- **Form Validation**: Real-time input validation

#### Performance Optimizations
- **Lazy Loading**: Load data as needed
- **Image Optimization**: Compressed and cached images
- **Debouncing**: Search input optimization
- **Build Optimization**: Const constructors
- **Widget Reusability**: Shared widget components
- **Memory Management**: Proper disposal of resources

#### Security Features
- **Secure Token Storage**: Flutter Secure Storage
- **HTTPS Only**: Encrypted API communication
- **Certificate Pinning**: Prevent man-in-the-middle attacks
- **Input Sanitization**: XSS prevention
- **Biometric Authentication**: Fingerprint/Face ID support (optional)
- **Auto-logout**: Session timeout handling

## 📂 Project Structure

```
campus_eats/
├── backend/              # Node.js REST API
│   ├── prisma/
│   │   └── schema.prisma # Database schema
│   ├── src/
│   │   ├── config/       # Configuration files
│   │   ├── routes/       # API routes
│   │   ├── middleware/   # Express middleware
│   │   ├── services/     # External services
│   │   ├── utils/        # Utility functions
│   │   └── server.js     # Entry point
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

## 🗄️ Database Schema (PostgreSQL)

The application uses PostgreSQL with Prisma ORM. Key database models include:

### Core Models

**University**
- Stores Ethiopian university information
- Fields: name, code, city, region, country
- Relations: campuses, users, lounges

**Campus**
- University campus locations
- Fields: name, address, coordinates (latitude, longitude)
- Relations: university, users, lounges

**User**
- All system users (students, staff, lounge owners, admins)
- Fields: name, phone, email, password, role, wallet balance
- Roles: USER, LOUNGE, ADMIN
- Relations: university, campus, lounges, orders, contracts, payments

**Lounge**
- Food service establishments
- Fields: name, description, logo, bank account details, operating hours, ratings
- Approval workflow: requires admin approval
- Relations: owner (user), university, campus, foods, orders, contracts, commissions

**Food**
- Menu items
- Fields: name, description, category, price, image, estimated time
- Categories: BREAKFAST, LUNCH, DINNER, SNACKS, DRINKS, DESSERT
- Additional: ingredients, allergens, vegetarian flag, spicy level
- Relations: lounge, order items

**Order**
- Food orders
- Fields: total price, status, payment method, QR code
- Statuses: PENDING, PREPARING, READY, DELIVERED, CANCELLED
- Payment methods: CONTRACT, CHAPA
- Relations: user, lounge, items, payment, contract, commissions

**OrderItem**
- Individual items in an order
- Fields: food name, quantity, price, subtotal, estimated time
- Relations: order, food

**Contract**
- Prepaid monthly food contracts
- Fields: total amount, remaining balance, start/expiry dates
- Relations: user, lounge, payment, orders

**Payment**
- All payment transactions
- Fields: amount, type, method, status, Chapa references
- Types: ORDER, CONTRACT, REFUND
- Statuses: PENDING, COMPLETED, FAILED, REFUNDED
- Relations: user, orders, contracts

**Commission**
- System commission tracking
- Fields: amount, rate, order amount, recipient, status
- Relations: order, lounge

### Database Features
- **UUID Primary Keys**: For security and scalability
- **Timestamps**: Automatic createdAt and updatedAt
- **Indexes**: Optimized queries on frequently accessed fields
- **Cascading Deletes**: Maintains referential integrity
- **JSONB Support**: For flexible metadata storage
- **Full-Text Search**: On lounge and food descriptions

### Migrations
Database migrations are managed by Prisma:
```bash
# Development: Create and apply new migration
npm run prisma:migrate
# This runs: prisma migrate dev

# Production: Apply existing migrations only
npx prisma migrate deploy

# Generate Prisma Client after schema changes
npm run prisma:generate

# View database in GUI
npm run prisma:studio
```

## 📝 API Documentation

### Base URL
```
Development: http://localhost:3000/api/v1
Production: https://your-domain.com/api/v1
```

### Authentication Endpoints

#### Register User
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "phone": "+251912345678",
  "email": "john@example.com",
  "password": "securePassword123",
  "universityId": "uuid",
  "campusId": "uuid",
  "role": "USER" // USER, LOUNGE, or ADMIN
}
```

#### Verify OTP
```http
POST /api/v1/auth/verify-otp
Content-Type: application/json

{
  "phone": "+251912345678",
  "otp": "123456"
}
```

#### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "phone": "+251912345678",
  "password": "securePassword123"
}
```

#### Resend OTP
```http
POST /api/v1/auth/resend-otp
Content-Type: application/json

{
  "phone": "+251912345678"
}
```

#### Get Current User
```http
GET /api/v1/auth/me
Authorization: Bearer {token}
```

### Lounge Endpoints

#### Get All Lounges
```http
GET /api/v1/lounges?universityId={id}&campusId={id}&search={query}
```

#### Get Lounge by ID
```http
GET /api/v1/lounges/:id
```

#### Create Lounge
```http
POST /api/v1/lounges
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Campus Café",
  "universityId": "uuid",
  "campusId": "uuid",
  "description": "Best coffee on campus",
  "logo": "https://example.com/logo.jpg",
  "bankAccount": {
    "accountNumber": "1234567890",
    "bankName": "Commercial Bank of Ethiopia",
    "accountHolderName": "John Doe"
  },
  "operatingHours": {
    "opening": "08:00",
    "closing": "18:00"
  }
}
```

#### Update Lounge
```http
PUT /api/v1/lounges/:id
Authorization: Bearer {token}
Content-Type: application/json
```

#### Get Lounge Menu
```http
GET /api/v1/lounges/:id/menu
```

### Food Endpoints

#### Get All Foods
```http
GET /api/v1/foods?loungeId={id}&category={BREAKFAST|LUNCH|DINNER|SNACKS|DRINKS|DESSERT}&search={query}&available={true|false}
```

#### Get Food by ID
```http
GET /api/v1/foods/:id
```

#### Create Food Item
```http
POST /api/v1/foods
Authorization: Bearer {token}
Content-Type: application/json

{
  "loungeId": "uuid",
  "name": "Injera with Wot",
  "description": "Traditional Ethiopian dish",
  "category": "LUNCH",
  "price": 45.00,
  "image": "https://example.com/food.jpg",
  "estimatedTime": 15,
  "ingredients": ["teff", "berbere", "meat"],
  "allergens": ["gluten"],
  "isVegetarian": false,
  "spicyLevel": "MEDIUM"
}
```

#### Update Food Item
```http
PUT /api/v1/foods/:id
Authorization: Bearer {token}
Content-Type: application/json
```

#### Delete Food Item
```http
DELETE /api/v1/foods/:id
Authorization: Bearer {token}
```

### Order Endpoints

#### Create Order
```http
POST /api/v1/orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "loungeId": "uuid",
  "items": [
    {
      "foodId": "uuid",
      "quantity": 2
    }
  ],
  "paymentMethod": "contract" // or "chapa",
  "contractId": "uuid" // required if paymentMethod is "contract"
}
```

#### Get Orders
```http
GET /api/v1/orders?status={PENDING|PREPARING|READY|DELIVERED|CANCELLED}&page=1&limit=10
Authorization: Bearer {token}
```

#### Get Order by ID
```http
GET /api/v1/orders/:id
Authorization: Bearer {token}
```

#### Update Order Status
```http
PUT /api/v1/orders/:id/status
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "PREPARING" // PENDING, PREPARING, READY, DELIVERED, CANCELLED
}
```

#### Verify QR Code
```http
POST /api/v1/orders/verify-qr
Authorization: Bearer {token}
Content-Type: application/json

{
  "qrCode": "encrypted-qr-string"
}
```

### Contract Endpoints

#### Create Contract
```http
POST /api/v1/contracts
Authorization: Bearer {token}
Content-Type: application/json

{
  "loungeId": "uuid",
  "totalAmount": 500.00,
  "durationDays": 30
}
```

#### Get User Contracts
```http
GET /api/v1/contracts?loungeId={id}&status={active|expired}
Authorization: Bearer {token}
```

#### Get Contract by ID
```http
GET /api/v1/contracts/:id
Authorization: Bearer {token}
```

#### Renew Contract
```http
POST /api/v1/contracts/:id/renew
Authorization: Bearer {token}
Content-Type: application/json

{
  "amount": 500.00,
  "durationDays": 30
}
```

#### Get Contract with Lounge
```http
GET /api/v1/contracts/lounge/:loungeId
Authorization: Bearer {token}
```

### Payment Endpoints

#### Initialize Payment
```http
POST /api/v1/payments/initialize
Authorization: Bearer {token}
Content-Type: application/json

{
  "paymentId": "uuid"
}
```

#### Payment Webhook (Chapa Callback)
```http
POST /api/v1/payments/webhook
Content-Type: application/json

{
  "tx_ref": "payment-reference",
  "status": "success",
  "transaction_id": "chapa-transaction-id"
}
```

#### Get User Payments
```http
GET /api/v1/payments?type={ORDER|CONTRACT|REFUND}&status={PENDING|COMPLETED|FAILED|REFUNDED}&page=1&limit=10
Authorization: Bearer {token}
```

#### Get Payment by ID
```http
GET /api/v1/payments/:id
Authorization: Bearer {token}
```

### User Endpoints

#### Get User Profile
```http
GET /api/v1/users/profile
Authorization: Bearer {token}
```

#### Update User Profile
```http
PUT /api/v1/users/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "fcmToken": "firebase-token"
}
```

#### Get Wallet Balance
```http
GET /api/v1/users/wallet
Authorization: Bearer {token}
```

#### Get User Contracts
```http
GET /api/v1/users/contracts
Authorization: Bearer {token}
```

#### Get User Orders
```http
GET /api/v1/users/orders?status={status}&page=1&limit=10
Authorization: Bearer {token}
```

### Commission Endpoints

#### Get Commissions
```http
GET /api/v1/commissions?loungeId={id}&status={PENDING|PAID|CANCELLED}&page=1&limit=10
Authorization: Bearer {token}
```

#### Get Commission Statistics
```http
GET /api/v1/commissions/stats
Authorization: Bearer {token}
```

#### Update Commission Status (Admin Only)
```http
PUT /api/v1/commissions/:id/status
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "PAID" // PENDING, PAID, or CANCELLED
}
```

#### Get Commission by ID
```http
GET /api/v1/commissions/:id
Authorization: Bearer {token}
```

### Admin Endpoints

#### Get System Statistics
```http
GET /api/v1/admin/stats
Authorization: Bearer {token}
```

#### Get All Users
```http
GET /api/v1/admin/users?role={USER|LOUNGE|ADMIN}&page=1&limit=10
Authorization: Bearer {token}
```

#### Update User Status
```http
PUT /api/v1/admin/users/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "isActive": true
}
```

#### Get All Lounges
```http
GET /api/v1/admin/lounges?status={pending|approved}&page=1&limit=10
Authorization: Bearer {token}
```

#### Approve/Reject Lounge
```http
PUT /api/v1/admin/lounges/:id/approve
Authorization: Bearer {token}
Content-Type: application/json

{
  "isApproved": true
}
```

#### Create University
```http
POST /api/v1/admin/universities
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Addis Ababa University",
  "code": "AAU",
  "city": "Addis Ababa",
  "region": "Addis Ababa"
}
```

#### Get All Universities
```http
GET /api/v1/admin/universities
Authorization: Bearer {token}
```

#### Create Campus
```http
POST /api/v1/admin/campuses
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Main Campus",
  "universityId": "uuid",
  "address": "Campus address",
  "latitude": 9.0054,
  "longitude": 38.7636
}
```

#### Get All Campuses
```http
GET /api/v1/admin/campuses?universityId={id}
Authorization: Bearer {token}
```

#### Get All Orders (Admin)
```http
GET /api/v1/admin/orders?status={status}&loungeId={id}&page=1&limit=10
Authorization: Bearer {token}
```

#### Get All Commissions (Admin)
```http
GET /api/v1/admin/commissions?loungeId={id}&status={status}&page=1&limit=10
Authorization: Bearer {token}
```

#### Get All Payments (Admin)
```http
GET /api/v1/admin/payments?type={type}&status={status}&page=1&limit=10
Authorization: Bearer {token}
```

### Response Format

All API responses follow this structure:

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ }
}
```

**Success Response with Pagination:**
```json
{
  "success": true,
  "data": [ /* array of items */ ],
  "pagination": {
    "total": 100,
    "page": 1,
    "pages": 10
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message"
}
```

### Authentication

Most endpoints require authentication. Include the JWT token in the Authorization header:

```http
Authorization: Bearer your-jwt-token
```

### Rate Limiting

API requests are rate-limited to:
- 100 requests per 15 minutes per IP address

### Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

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
- Deploy to Heroku, AWS, DigitalOcean, Railway, or any Node.js host
- Set up PostgreSQL database (recommended: managed service like AWS RDS, DigitalOcean Managed Databases, or Railway PostgreSQL)
- Configure environment variables (DATABASE_URL, JWT_SECRET, etc.)
- **Run database migrations**: `npx prisma migrate deploy` (production)
- Generate Prisma Client: `npx prisma generate`
- Set up Chapa webhook URL
- Configure CORS for frontend domain

### Database Setup
- PostgreSQL 12 or higher required
- Prisma ORM handles migrations
- Connection string format: `postgresql://username:password@host:5432/database`
- **Important**: Use `npx prisma migrate deploy` in production (applies existing migrations)
- Use `npm run prisma:migrate` only in development (creates new migrations)

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

