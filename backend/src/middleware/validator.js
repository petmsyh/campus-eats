const { body, param, query, validationResult } = require('express-validator');
const { ValidationError } = require('../utils/errors');

/**
 * Middleware to handle validation errors
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map((error) => error.msg);
    throw new ValidationError(errorMessages.join(', '));
  }
  next();
};

/**
 * Common validation rules
 */
const commonValidations = {
  id: param('id').isUUID().withMessage('Invalid ID format'),
  
  pagination: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Page must be a positive integer'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100'),
  ],

  phone: body('phone')
    .matches(/^\+251\d{9}$/)
    .withMessage('Phone must be in format +251XXXXXXXXX'),

  email: body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Invalid email format'),

  password: body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain uppercase, lowercase, and number'),

  name: body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters')
    .matches(/^[a-zA-Z\s]+$/)
    .withMessage('Name can only contain letters and spaces'),

  uuid: (field) => body(field).isUUID().withMessage(`Invalid ${field} format`),
};

/**
 * Authentication validation rules
 */
const authValidations = {
  register: [
    commonValidations.name,
    commonValidations.phone,
    commonValidations.email,
    commonValidations.password,
    body('universityId').isUUID().withMessage('Invalid university ID'),
    body('campusId').isUUID().withMessage('Invalid campus ID'),
    body('role')
      .optional()
      .isIn(['USER', 'LOUNGE', 'ADMIN'])
      .withMessage('Invalid role'),
  ],

  login: [
    commonValidations.phone,
    body('password').notEmpty().withMessage('Password is required'),
  ],

  verifyOtp: [
    commonValidations.phone,
    body('otp')
      .isLength({ min: 6, max: 6 })
      .isNumeric()
      .withMessage('OTP must be 6 digits'),
  ],

  resendOtp: [commonValidations.phone],
};

/**
 * Order validation rules
 */
const orderValidations = {
  create: [
    body('loungeId').isUUID().withMessage('Invalid lounge ID'),
    body('items')
      .isArray({ min: 1 })
      .withMessage('Order must contain at least one item'),
    body('items.*.foodId').isUUID().withMessage('Invalid food ID'),
    body('items.*.quantity')
      .isInt({ min: 1, max: 50 })
      .withMessage('Quantity must be between 1 and 50'),
    body('paymentMethod')
      .isIn(['contract', 'chapa'])
      .withMessage('Invalid payment method'),
    body('contractId')
      .optional()
      .isUUID()
      .withMessage('Invalid contract ID'),
  ],

  updateStatus: [
    commonValidations.id,
    body('status')
      .isIn(['PENDING', 'PREPARING', 'READY', 'DELIVERED', 'CANCELLED'])
      .withMessage('Invalid status'),
  ],

  verifyQr: [
    body('qrCode')
      .notEmpty()
      .isLength({ min: 10 })
      .withMessage('Invalid QR code'),
  ],
};

/**
 * Food validation rules
 */
const foodValidations = {
  create: [
    body('loungeId').isUUID().withMessage('Invalid lounge ID'),
    body('name')
      .trim()
      .isLength({ min: 2, max: 200 })
      .withMessage('Food name must be between 2 and 200 characters'),
    body('description')
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters'),
    body('category')
      .isIn(['BREAKFAST', 'LUNCH', 'DINNER', 'SNACKS', 'DRINKS', 'DESSERT'])
      .withMessage('Invalid category'),
    body('price')
      .isFloat({ min: 0.01, max: 10000 })
      .withMessage('Price must be between 0.01 and 10000'),
    body('estimatedTime')
      .optional()
      .isInt({ min: 1, max: 240 })
      .withMessage('Estimated time must be between 1 and 240 minutes'),
    body('isVegetarian')
      .optional()
      .isBoolean()
      .withMessage('isVegetarian must be boolean'),
    body('spicyLevel')
      .optional()
      .isIn(['NONE', 'MILD', 'MEDIUM', 'HOT', 'EXTRA_HOT'])
      .withMessage('Invalid spicy level'),
  ],

  update: [
    commonValidations.id,
    body('name')
      .optional()
      .trim()
      .isLength({ min: 2, max: 200 })
      .withMessage('Food name must be between 2 and 200 characters'),
    body('price')
      .optional()
      .isFloat({ min: 0.01, max: 10000 })
      .withMessage('Price must be between 0.01 and 10000'),
    body('isAvailable')
      .optional()
      .isBoolean()
      .withMessage('isAvailable must be boolean'),
  ],
};

/**
 * Lounge validation rules
 */
const loungeValidations = {
  create: [
    body('name')
      .trim()
      .isLength({ min: 2, max: 200 })
      .withMessage('Lounge name must be between 2 and 200 characters'),
    body('universityId').isUUID().withMessage('Invalid university ID'),
    body('campusId').isUUID().withMessage('Invalid campus ID'),
    body('description')
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters'),
  ],

  update: [
    commonValidations.id,
    body('name')
      .optional()
      .trim()
      .isLength({ min: 2, max: 200 })
      .withMessage('Lounge name must be between 2 and 200 characters'),
  ],
};

/**
 * Contract validation rules
 */
const contractValidations = {
  create: [
    body('loungeId').isUUID().withMessage('Invalid lounge ID'),
    body('totalAmount')
      .isFloat({ min: 50, max: 50000 })
      .withMessage('Amount must be between 50 and 50000'),
    body('durationDays')
      .isInt({ min: 1, max: 365 })
      .withMessage('Duration must be between 1 and 365 days'),
  ],
};

/**
 * Sanitize output to prevent XSS
 */
const sanitizeOutput = (obj) => {
  if (typeof obj !== 'object' || obj === null) {
    return obj;
  }

  const sanitized = Array.isArray(obj) ? [] : {};
  
  for (const key in obj) {
    if (obj.hasOwnProperty(key)) {
      const value = obj[key];
      
      if (typeof value === 'string') {
        // Basic XSS protection - remove script tags and sanitize
        sanitized[key] = value
          .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
          .replace(/javascript:/gi, '')
          .replace(/on\w+\s*=/gi, '');
      } else if (typeof value === 'object' && value !== null) {
        sanitized[key] = sanitizeOutput(value);
      } else {
        sanitized[key] = value;
      }
    }
  }
  
  return sanitized;
};

module.exports = {
  validate,
  commonValidations,
  authValidations,
  orderValidations,
  foodValidations,
  loungeValidations,
  contractValidations,
  sanitizeOutput,
};
