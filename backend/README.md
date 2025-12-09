# Campus Eats - Backend API

Ethiopian Universities Food Ordering & Lounge Management System - Backend REST API

## 📋 Overview

This is the backend API for Campus Eats, a comprehensive food ordering system designed for Ethiopian universities. It provides RESTful endpoints for user authentication, lounge management, food ordering, contract management, and payment processing.

## 🚀 Features

- **Authentication**: JWT-based authentication with OTP verification
- **User Management**: User profiles, wallet management, and role-based access control
- **Lounge Management**: Restaurant/lounge registration, approval, and menu management
- **Food Ordering**: Complete order lifecycle from cart to delivery
- **Contract System**: Prepaid monthly contracts with wallet balance
- **Payment Integration**: Chapa payment gateway integration
- **QR Code System**: Order verification using QR codes
- **Commission Tracking**: Automated commission calculation and reporting
- **Push Notifications**: FCM integration for real-time updates
- **Admin Panel**: Comprehensive admin controls and analytics

## 🛠️ Tech Stack

- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Payment**: Chapa Payment Gateway
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Logging**: Winston
- **Security**: Helmet, bcryptjs, rate-limiting

## 📦 Installation

### Prerequisites

- Node.js v18 or higher
- MongoDB instance (local or cloud)
- Chapa account for payment integration
- Firebase project for FCM notifications

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/petmsyh/campus_eats.git
   cd campus_eats/backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and configure:
   - `MONGODB_URI`: Your MongoDB connection string
   - `JWT_SECRET`: Secret key for JWT tokens
   - `CHAPA_SECRET_KEY`: Your Chapa secret key
   - `FCM_*`: Firebase Cloud Messaging credentials

4. **Start the server**
   ```bash
   # Development mode
   npm run dev

   # Production mode
   npm start
   ```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment (development/production) | development |
| `PORT` | Server port | 3000 |
| `MONGODB_URI` | MongoDB connection string | - |
| `JWT_SECRET` | JWT secret key | - |
| `JWT_EXPIRES_IN` | JWT expiration time | 7d |
| `CHAPA_SECRET_KEY` | Chapa payment secret key | - |
| `FCM_SERVER_KEY` | Firebase FCM server key | - |
| `SYSTEM_COMMISSION_RATE` | Commission rate (0-1) | 0.05 |

See `.env.example` for complete configuration.

## 📚 API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "phone": "+251912345678",
  "email": "john@example.com",
  "password": "password123",
  "universityId": "universityId",
  "campusId": "campusId"
}
```

#### Verify OTP
```http
POST /auth/verify-otp
Content-Type: application/json

{
  "phone": "+251912345678",
  "otp": "123456"
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "phone": "+251912345678",
  "password": "password123"
}
```

### Order Endpoints

#### Create Order
```http
POST /orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "loungeId": "loungeId",
  "items": [
    {
      "foodId": "foodId",
      "quantity": 2
    }
  ],
  "paymentMethod": "contract",
  "contractId": "contractId"
}
```

#### Get Orders
```http
GET /orders?status=pending&page=1&limit=10
Authorization: Bearer {token}
```

#### Update Order Status
```http
PUT /orders/:id/status
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "ready"
}
```

#### Verify QR Code
```http
POST /orders/verify-qr
Authorization: Bearer {token}
Content-Type: application/json

{
  "qrCode": "CE-orderId-timestamp-random"
}
```

### Complete API documentation available at `/docs` (when implemented)

## 🔒 Security

- **JWT Authentication**: All protected routes require valid JWT tokens
- **Password Hashing**: Bcrypt with salt rounds for password security
- **Rate Limiting**: API rate limiting to prevent abuse
- **Helmet**: Security headers middleware
- **CORS**: Configured CORS policies
- **Input Validation**: Express-validator for request validation

## 🏗️ Project Structure

```
backend/
├── src/
│   ├── config/          # Configuration files
│   │   └── database.js  # MongoDB connection
│   ├── models/          # Mongoose models
│   │   ├── User.js
│   │   ├── Lounge.js
│   │   ├── Food.js
│   │   ├── Order.js
│   │   ├── Contract.js
│   │   ├── Payment.js
│   │   └── Commission.js
│   ├── routes/          # API routes
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   ├── lounge.routes.js
│   │   ├── food.routes.js
│   │   ├── order.routes.js
│   │   ├── contract.routes.js
│   │   ├── payment.routes.js
│   │   ├── commission.routes.js
│   │   └── admin.routes.js
│   ├── middleware/      # Express middleware
│   │   ├── auth.js
│   │   ├── errorHandler.js
│   │   └── rateLimiter.js
│   ├── services/        # External services
│   │   ├── chapa.service.js
│   │   └── notification.service.js
│   ├── utils/           # Utility functions
│   │   ├── jwt.js
│   │   ├── qrcode.js
│   │   ├── otp.js
│   │   └── logger.js
│   └── server.js        # Entry point
├── logs/                # Application logs
├── .env.example         # Environment variables template
├── .gitignore
├── package.json
└── README.md
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm test -- --coverage
```

## 📝 Scripts

- `npm start` - Start production server
- `npm run dev` - Start development server with nodemon
- `npm test` - Run tests
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix linting issues

## 🚢 Deployment

### Docker Deployment

```dockerfile
# Dockerfile example
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Environment Setup

1. Set up MongoDB (MongoDB Atlas recommended)
2. Configure environment variables
3. Set up Chapa payment gateway
4. Configure Firebase FCM
5. Deploy to your preferred platform (Heroku, AWS, DigitalOcean, etc.)

## 📊 Database Schema

### User
- Authentication and profile information
- Wallet balance
- University and campus affiliation
- Role-based access

### Lounge
- Restaurant information
- Bank account details
- Operating hours
- Approval status

### Food
- Menu items
- Pricing and availability
- Estimated preparation time
- Categories and ratings

### Order
- Order items and total
- Payment method
- QR code for verification
- Order status tracking

### Contract
- Prepaid monthly contracts
- Balance tracking
- Expiration management

### Payment
- Chapa payment integration
- Transaction tracking
- Commission calculation

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Support

For support, email support@campuseats.et or join our Telegram channel.

## 🔄 Version

Current Version: 2.0.0

## 📱 Related Projects

- [Campus Eats Mobile App](../frontend) - Flutter mobile application
