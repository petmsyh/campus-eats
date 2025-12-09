# Future Improvements & TODO

## Overview

This document tracks potential improvements and enhancements for the Campus Eats system. The current implementation is production-ready, but these items would further improve security, performance, and maintainability.

---

## 🔒 Security Enhancements

### 1. QR Code Timestamp Validation (Medium Priority)
**Status**: Enhancement  
**Current**: QR codes validate format but not timestamp  
**Improvement**: Add time-window validation to prevent replay attacks

**Implementation:**
```javascript
// In utils/qrcode.js
const verifyQRCode = (qrData) => {
  try {
    const parts = qrData.split('-');
    if (parts.length !== 4 || parts[0] !== 'CE') {
      return { valid: false, orderId: null };
    }

    const orderId = parts[1];
    const timestamp = parseInt(parts[2]);
    const now = Date.now();
    
    // QR code valid for 24 hours
    const validityWindow = 24 * 60 * 60 * 1000;
    if (now - timestamp > validityWindow) {
      return { valid: false, orderId: null, reason: 'expired' };
    }

    return { valid: true, orderId };
  } catch (error) {
    return { valid: false, orderId: null };
  }
};
```

**Benefit**: Prevents old QR codes from being reused maliciously

---

### 2. Password Complexity Requirements (High Priority for Production)
**Status**: Recommended for production  
**Current**: Minimum 6 characters  
**Improvement**: Increase to 8+ characters with complexity rules

**Implementation:**
```javascript
// In validators or middleware
const passwordValidator = {
  minLength: 8,
  requireUppercase: true,
  requireLowercase: true,
  requireNumbers: true,
  requireSpecialChars: false
};

// Validation function
const validatePassword = (password) => {
  if (password.length < passwordValidator.minLength) {
    return { valid: false, message: 'Password must be at least 8 characters' };
  }
  if (passwordValidator.requireUppercase && !/[A-Z]/.test(password)) {
    return { valid: false, message: 'Password must contain uppercase letter' };
  }
  if (passwordValidator.requireLowercase && !/[a-z]/.test(password)) {
    return { valid: false, message: 'Password must contain lowercase letter' };
  }
  if (passwordValidator.requireNumbers && !/\d/.test(password)) {
    return { valid: false, message: 'Password must contain a number' };
  }
  return { valid: true };
};
```

**Benefit**: Stronger account security

---

### 3. Docker Secrets Management (High Priority for Production)
**Status**: Required for production deployment  
**Current**: Hard-coded credentials in docker-compose.yml  
**Improvement**: Use Docker secrets or environment files

**Implementation:**
```yaml
# docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:7.0
    environment:
      MONGO_INITDB_ROOT_USERNAME_FILE: /run/secrets/mongo_user
      MONGO_INITDB_ROOT_PASSWORD_FILE: /run/secrets/mongo_password
    secrets:
      - mongo_user
      - mongo_password

secrets:
  mongo_user:
    file: ./secrets/mongo_user.txt
  mongo_password:
    file: ./secrets/mongo_password.txt
```

**Benefit**: Secure credential management in Docker

---

## 🔧 Code Quality Improvements

### 4. Commission Rate Centralization (Low Priority)
**Status**: Code improvement  
**Current**: Commission rate calculation repeated in multiple places  
**Improvement**: Create a centralized commission service

**Implementation:**
```javascript
// services/commission.service.js
class CommissionService {
  constructor() {
    this.defaultRate = parseFloat(process.env.SYSTEM_COMMISSION_RATE) || 0.05;
  }

  calculateCommission(orderAmount) {
    return orderAmount * this.defaultRate;
  }

  getRate() {
    return this.defaultRate;
  }

  // Could add dynamic rates per lounge
  getRateForLounge(loungeId) {
    // Future: fetch from database
    return this.defaultRate;
  }
}

module.exports = new CommissionService();
```

**Usage:**
```javascript
const commissionService = require('../services/commission.service');
const commission = commissionService.calculateCommission(totalPrice);
```

**Benefit**: DRY principle, easier to maintain and modify

---

### 5. Frontend Logging Framework (Medium Priority)
**Status**: Enhancement  
**Current**: Temporary print statements with TODO  
**Improvement**: Implement proper logger package

**Implementation:**
```dart
// utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(dynamic message) {
    _logger.d(message);
  }

  static void info(dynamic message) {
    _logger.i(message);
  }

  static void warning(dynamic message) {
    _logger.w(message);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }
}

// In api_client.dart
import '../utils/logger.dart';

logPrint: (obj) {
  assert(() {
    AppLogger.debug(obj);
    return true;
  }());
},
```

**Benefit**: Better structured logging, easier debugging

---

## 🚀 Feature Enhancements

### 6. SMS Service Integration (High Priority for Production)
**Status**: **Required for production**  
**Current**: OTP logged to console in development  
**Improvement**: Integrate with SMS provider

**Recommended Providers for Ethiopia:**
- Africa's Talking (African markets)
- Twilio (Global)
- Infobip
- Ethio Telecom API (if available)

**Implementation Example (Africa's Talking):**
```javascript
// services/sms.service.js
const AfricasTalking = require('africastalking');

class SMSService {
  constructor() {
    this.client = AfricasTalking({
      apiKey: process.env.AFRICASTALKING_API_KEY,
      username: process.env.AFRICASTALKING_USERNAME
    });
    this.sms = this.client.SMS;
  }

  async sendOTP(phone, otp) {
    try {
      const result = await this.sms.send({
        to: [phone],
        message: `Your Campus Eats verification code is: ${otp}. Valid for 10 minutes.`,
        from: process.env.AFRICASTALKING_SENDER_ID
      });
      return { success: true, result };
    } catch (error) {
      logger.error('SMS sending failed:', error);
      return { success: false, error };
    }
  }
}

module.exports = new SMSService();
```

**Cost**: ~$0.01 per SMS (varies by provider)

---

### 7. Rate Limiting Per User (Medium Priority)
**Status**: Enhancement  
**Current**: Rate limiting by IP  
**Improvement**: Add per-user rate limiting

**Implementation:**
```javascript
// middleware/userRateLimiter.js
const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');

const userRateLimiter = rateLimit({
  store: new RedisStore({
    // Redis connection
  }),
  windowMs: 15 * 60 * 1000,
  max: 200, // Higher limit per user
  keyGenerator: (req) => req.user?.id || req.ip,
  message: 'Too many requests from this account'
});
```

**Benefit**: More granular rate limiting

---

### 8. Order Caching with Redis (Low Priority)
**Status**: Performance enhancement  
**Current**: Direct database queries  
**Improvement**: Cache frequently accessed orders

**Implementation:**
```javascript
// services/cache.service.js
const redis = require('redis');

class CacheService {
  constructor() {
    this.client = redis.createClient({
      url: process.env.REDIS_URL
    });
  }

  async cacheOrder(orderId, orderData, ttl = 3600) {
    await this.client.setEx(
      `order:${orderId}`,
      ttl,
      JSON.stringify(orderData)
    );
  }

  async getOrder(orderId) {
    const cached = await this.client.get(`order:${orderId}`);
    return cached ? JSON.parse(cached) : null;
  }
}
```

**Benefit**: Faster response times, reduced database load

---

## 📱 Mobile App Enhancements

### 9. Biometric Authentication (Medium Priority)
**Status**: Feature enhancement  
**Improvement**: Add fingerprint/face ID login

**Implementation:**
```dart
dependencies:
  local_auth: ^2.1.0

// services/auth_service.dart
Future<bool> authenticateWithBiometrics() async {
  final LocalAuthentication auth = LocalAuthentication();
  
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();
  
  if (!canAuthenticate) return false;
  
  try {
    return await auth.authenticate(
      localizedReason: 'Please authenticate to access Campus Eats',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  } catch (e) {
    return false;
  }
}
```

**Benefit**: Enhanced user experience and security

---

### 10. Offline Order Queue (Medium Priority)
**Status**: Feature enhancement  
**Improvement**: Queue orders when offline, sync when online

**Implementation:**
```dart
// services/offline_order_service.dart
class OfflineOrderService {
  final Box<PendingOrder> _box;

  Future<void> queueOrder(Order order) async {
    await _box.add(PendingOrder.fromOrder(order));
  }

  Future<void> syncPendingOrders() async {
    final pending = _box.values.toList();
    
    for (final order in pending) {
      try {
        await apiClient.createOrder(order);
        await _box.delete(order.key);
      } catch (e) {
        // Will retry next time
      }
    }
  }
}
```

**Benefit**: Better user experience in poor connectivity areas

---

## 📊 Analytics & Monitoring

### 11. Analytics Dashboard (Low Priority)
**Status**: Feature enhancement  
**Improvement**: Add analytics for order patterns, peak hours, popular items

**Implementation:**
```javascript
// services/analytics.service.js
class AnalyticsService {
  async getOrderStats(loungeId, startDate, endDate) {
    return await Order.aggregate([
      {
        $match: {
          loungeId,
          createdAt: { $gte: startDate, $lte: endDate }
        }
      },
      {
        $group: {
          _id: {
            hour: { $hour: '$createdAt' },
            day: { $dayOfWeek: '$createdAt' }
          },
          count: { $sum: 1 },
          revenue: { $sum: '$totalPrice' }
        }
      }
    ]);
  }

  async getPopularItems(loungeId, limit = 10) {
    return await Order.aggregate([
      { $match: { loungeId } },
      { $unwind: '$items' },
      {
        $group: {
          _id: '$items.foodId',
          name: { $first: '$items.name' },
          totalOrders: { $sum: '$items.quantity' },
          revenue: { $sum: '$items.subtotal' }
        }
      },
      { $sort: { totalOrders: -1 } },
      { $limit: limit }
    ]);
  }
}
```

**Benefit**: Data-driven decision making for lounges

---

### 12. Error Monitoring (Medium Priority)
**Status**: Recommended for production  
**Improvement**: Integrate Sentry or similar service

**Implementation:**
```javascript
// Backend
const Sentry = require('@sentry/node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});

app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.errorHandler());
```

```dart
// Frontend
import 'package:sentry_flutter/sentry_flutter.dart';

await SentryFlutter.init(
  (options) {
    options.dsn = 'your-dsn';
    options.environment = 'production';
  },
  appRunner: () => runApp(MyApp()),
);
```

**Benefit**: Proactive error detection and resolution

---

## 🧪 Testing

### 13. Backend Test Suite (High Priority)
**Status**: Framework ready, tests to be written  
**Improvement**: Comprehensive test coverage

**Implementation:**
```javascript
// tests/auth.test.js
describe('Authentication', () => {
  test('should register new user', async () => {
    const response = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'Test User',
        phone: '+251912345678',
        password: 'password123',
        universityId: testUniversityId,
        campusId: testCampusId
      });
    
    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
  });

  test('should reject duplicate phone numbers', async () => {
    // Test implementation
  });
});
```

**Target Coverage**: 80%+

---

### 14. Flutter Integration Tests (Medium Priority)
**Status**: To be implemented  
**Improvement**: End-to-end testing

**Implementation:**
```dart
// integration_test/order_flow_test.dart
void main() {
  testWidgets('Complete order flow', (tester) async {
    await tester.pumpWidget(MyApp());
    
    // Login
    await tester.enterText(find.byType(TextField).first, '+251912345678');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    
    // Browse and order
    await tester.tap(find.text('Main Campus Lounge'));
    await tester.pumpAndSettle();
    
    // Add assertions
    expect(find.text('Menu'), findsOneWidget);
  });
}
```

---

## 🚀 CI/CD Pipeline

### 15. GitHub Actions Workflow (High Priority)
**Status**: To be implemented  
**Improvement**: Automated testing and deployment

**Implementation:**
```yaml
# .github/workflows/backend.yml
name: Backend CI/CD

on:
  push:
    branches: [ main ]
    paths:
      - 'backend/**'
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mongodb:
        image: mongo:7.0
        ports:
          - 27017:27017
    
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: cd backend && npm ci
      
      - name: Run tests
        run: cd backend && npm test
      
      - name: Run linter
        run: cd backend && npm run lint
  
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    steps:
      - name: Deploy to Heroku
        # Deployment steps
```

---

## 📋 Priority Matrix

| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| **High** | SMS Integration | Medium | High |
| **High** | Password Complexity | Low | High |
| **High** | Docker Secrets | Low | High |
| **High** | Backend Tests | High | High |
| **High** | CI/CD Pipeline | Medium | High |
| **Medium** | QR Timestamp Validation | Low | Medium |
| **Medium** | Frontend Logger | Low | Low |
| **Medium** | Error Monitoring | Low | High |
| **Medium** | Biometric Auth | Medium | Medium |
| **Medium** | Offline Orders | Medium | Medium |
| **Low** | Commission Service | Low | Low |
| **Low** | Order Caching | Medium | Medium |
| **Low** | Analytics Dashboard | High | Medium |

---

## 📅 Suggested Roadmap

### Phase 1: Production Essentials (Week 1-2)
1. SMS service integration
2. Password complexity requirements
3. Docker secrets management
4. Basic backend tests

### Phase 2: Quality & Monitoring (Week 3-4)
5. Error monitoring (Sentry)
6. CI/CD pipeline
7. Frontend logging framework
8. QR timestamp validation

### Phase 3: Features & Performance (Week 5-8)
9. Biometric authentication
10. Offline order queue
11. Rate limiting per user
12. Commission service refactor

### Phase 4: Analytics & Advanced (Week 9-12)
13. Analytics dashboard
14. Order caching with Redis
15. Integration tests
16. Security audit

---

## 📝 Notes

- Current implementation is **production-ready** but these improvements would enhance it further
- Priority should be given to SMS integration for production deployment
- All code suggestions are examples and should be adapted to project needs
- Regular security audits recommended every 6 months

---

**Last Updated**: December 2024  
**Status**: Reference document for future development
