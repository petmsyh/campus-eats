require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { connectDB } = require('./config/prisma');
const logger = require('./utils/logger');
const errorHandler = require('./middleware/errorHandler');
const rateLimiter = require('./middleware/rateLimiter');
const {
  apiLimiter,
  authLimiter,
  requestSizeLimiter,
  sqlInjectionProtection,
  noSqlInjectionProtection,
  xssProtection,
} = require('./middleware/security');

// Import routes
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const loungeRoutes = require('./routes/lounge.routes');
const foodRoutes = require('./routes/food.routes');
const orderRoutes = require('./routes/order.routes');
const contractRoutes = require('./routes/contract.routes');
const paymentRoutes = require('./routes/payment.routes');
const commissionRoutes = require('./routes/commission.routes');
const adminRoutes = require('./routes/admin.routes');
const referenceRoutes = require('./routes/reference.routes');

const app = express();

// Connect to Database
connectDB();

// Security Middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
}));

app.use(cors({
  origin: process.env.FRONTEND_URL || (process.env.NODE_ENV === 'development' ? 'http://localhost:3001' : false),
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Request size limits
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.use(morgan('combined', { stream: { write: (message) => logger.info(message.trim()) } }));

// Security middleware
app.use(requestSizeLimiter);
app.use(sqlInjectionProtection);
app.use(noSqlInjectionProtection);
app.use(xssProtection);

// Rate limiting
app.use('/api/', apiLimiter);
app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/register', authLimiter);
app.use('/api/v1/auth/verify-otp', authLimiter);
app.use('/api/v1/auth/resend-otp', authLimiter);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'Campus Eats API is running',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/lounges', loungeRoutes);
app.use('/api/v1/foods', foodRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/contracts', contractRoutes);
app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/commissions', commissionRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/reference', referenceRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handler
app.use(errorHandler);

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  logger.info(`🚀 Server is running on port ${PORT}`);
  logger.info(`📱 Environment: ${process.env.NODE_ENV}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  logger.error('Unhandled Promise Rejection:', err);
  server.close(() => process.exit(1));
});

module.exports = app;
