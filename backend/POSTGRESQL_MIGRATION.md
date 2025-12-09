# PostgreSQL Migration with Prisma - Campus Eats

## Migration Status

This repository has been migrated from MongoDB/Mongoose to PostgreSQL/Prisma.

### ✅ Completed

1. **Database Setup**
   - Installed Prisma CLI and client (v7.1.0)
   - Created comprehensive Prisma schema with all models
   - Set up database configuration file (`src/config/prisma.js`)
   - Removed Mongoose dependency

2. **Schema Definition**
   - User model with authentication fields
   - University and Campus models with relations
   - Lounge model with owner relations
   - Food model with category enums
   - Order model with OrderItem join table
   - Contract model with expiration tracking
   - Payment model with transaction tracking
   - Commission model for system fees

3. **Middleware & Utilities**
   - Updated authentication middleware to use Prisma
   - Created password hashing utilities (`src/utils/userHelpers.js`)
   - Updated server configuration

4. **Route Files Updated**
   - ✅ `auth.routes.js` - Registration, login, OTP verification
   - ✅ `user.routes.js` - User profile, wallet, contracts, orders
   - ✅ `lounge.routes.js` - Lounge CRUD and menu
   - ✅ `food.routes.js` - Food item management
   - ✅ `order.routes.js` - Order creation, status updates, QR verification

5. **Route Files Pending**
   - ⏳ `contract.routes.js` - Needs Prisma conversion
   - ⏳ `payment.routes.js` - Needs Prisma conversion
   - ⏳ `commission.routes.js` - Needs Prisma conversion
   - ⏳ `admin.routes.js` - Needs Prisma conversion

### 📋 Setup Instructions

#### 1. Environment Configuration

Create a `.env` file in the `backend` directory:

```env
# Environment
NODE_ENV=development
PORT=3000

# PostgreSQL Database (Prisma 7 format)
DATABASE_URL=postgresql://username:password@localhost:5432/campus_eats?schema=public

# JWT Configuration
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRES_IN=30d

# OTP Configuration
OTP_EXPIRY_MINUTES=10
OTP_LENGTH=6

# Chapa Payment
CHAPA_SECRET_KEY=your-chapa-secret-key
CHAPA_PUBLIC_KEY=your-chapa-public-key
CHAPA_WEBHOOK_URL=https://your-domain.com/api/v1/payments/webhook
CHAPA_CALLBACK_URL=https://your-domain.com/api/v1/payments/callback

# Commission Configuration
SYSTEM_COMMISSION_RATE=0.05

# Firebase Cloud Messaging
FCM_SERVER_KEY=your-fcm-server-key
FCM_PROJECT_ID=your-firebase-project-id
FCM_PRIVATE_KEY=your-firebase-private-key
FCM_CLIENT_EMAIL=your-firebase-client-email

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3001

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info
```

Note: In Prisma 7, the `DATABASE_URL` must also be set in `prisma.config.ts`.

#### 2. Database Setup

```bash
# Install dependencies
cd backend
npm install

# Generate Prisma Client
npm run prisma:generate

# Run database migrations (creates tables)
npm run prisma:migrate

# Alternatively, push schema directly (for development)
npm run prisma:push

# Optional: Open Prisma Studio to view/edit data
npm run prisma:studio
```

#### 3. Run the Application

```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

### 🔄 Key Changes from MongoDB to PostgreSQL

#### 1. ID Fields
- MongoDB: `_id` (ObjectId)
- PostgreSQL: `id` (UUID string)

#### 2. Enum Values
- MongoDB: lowercase strings (e.g., `'user'`, `'pending'`)
- PostgreSQL: UPPERCASE enums (e.g., `'USER'`, `'PENDING'`)
- Updated in routes to use `.toUpperCase()` conversion

#### 3. Relations
- MongoDB: References with `populate()`
- Prisma: `include` for eager loading relations

Example:
```javascript
// MongoDB
await User.findById(id).populate('universityId', 'name code')

// Prisma
await prisma.user.findUnique({
  where: { id },
  include: {
    university: { select: { name: true, code: true } }
  }
})
```

#### 4. Queries
- MongoDB: `find()`, `findOne()`, `findById()`
- Prisma: `findMany()`, `findFirst()`, `findUnique()`

#### 5. Updates
- MongoDB: `findByIdAndUpdate()`, `save()`
- Prisma: `update()`, `updateMany()`

#### 6. Text Search
- MongoDB: `$regex` operator
- Prisma: `contains` with `mode: 'insensitive'`

#### 7. Nested Documents
- MongoDB: Embedded documents (e.g., `otp: { code, expiresAt }`)
- PostgreSQL: Flattened fields (e.g., `otpCode`, `otpExpiresAt`)

### 📝 Migration Patterns

#### Model Usage Pattern
```javascript
// Old (Mongoose)
const User = require('../models/User');
const user = await User.findById(id);

// New (Prisma)
const { prisma } = require('../config/prisma');
const user = await prisma.user.findUnique({ where: { id } });
```

#### Create with Relations
```javascript
// Old (Mongoose)
const order = new Order({ userId, loungeId, items: [...] });
await order.save();

// New (Prisma)
const order = await prisma.order.create({
  data: {
    userId,
    loungeId,
    items: {
      create: [...]
    }
  }
});
```

### 🔧 Remaining Tasks

1. **Update Remaining Routes**
   - Convert `contract.routes.js` to Prisma queries
   - Convert `payment.routes.js` to Prisma queries
   - Convert `commission.routes.js` to Prisma queries
   - Convert `admin.routes.js` to Prisma queries

2. **Testing**
   - Test user registration and authentication
   - Test order creation with contract payment
   - Test order creation with Chapa payment
   - Test lounge management
   - Test food item management
   - Test admin functionalities

3. **Data Migration** (if migrating existing data)
   - Export data from MongoDB
   - Transform data format (IDs, enums, nested objects)
   - Import data into PostgreSQL

### 🐛 Common Issues & Solutions

#### Issue: Prisma Client not generated
**Solution:**
```bash
npm run prisma:generate
```

#### Issue: Database connection error
**Solution:**
- Verify `DATABASE_URL` in `.env` file
- Ensure PostgreSQL is running
- Check database credentials

#### Issue: Enum mismatch errors
**Solution:**
- Ensure enum values are uppercase in API calls
- Use `.toUpperCase()` when setting enum fields

#### Issue: Relation not found
**Solution:**
- Ensure foreign key IDs exist before creating relations
- Use `include` to load relations when needed

### 📚 Resources

- [Prisma Documentation](https://www.prisma.io/docs/)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### 🎯 Next Steps

1. Complete the remaining route file migrations
2. Set up a PostgreSQL database (local or cloud)
3. Run migrations to create database schema
4. Test all API endpoints
5. Update frontend to handle UUID IDs instead of MongoDB ObjectIDs
6. Deploy to production

### 📞 Support

For issues or questions about the migration:
- Check Prisma documentation
- Review the updated route files for patterns
- Consult PostgreSQL documentation for database-specific queries
