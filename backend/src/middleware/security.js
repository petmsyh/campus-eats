const rateLimit = require('express-rate-limit');

/**
 * General API rate limiter
 */
const apiLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Strict rate limiter for authentication endpoints
 */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 requests per windowMs
  skipSuccessfulRequests: true,
  message: {
    success: false,
    message: 'Too many authentication attempts, please try again after 15 minutes.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Payment endpoints rate limiter
 */
const paymentLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20,
  message: {
    success: false,
    message: 'Too many payment requests, please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * OTP rate limiter
 */
const otpLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // Maximum 3 OTP requests per hour
  message: {
    success: false,
    message: 'Too many OTP requests, please try again after an hour.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Request size limit middleware
 */
const requestSizeLimiter = (req, res, next) => {
  const MAX_SIZE = 10 * 1024 * 1024; // 10MB
  
  if (req.headers['content-length'] && parseInt(req.headers['content-length']) > MAX_SIZE) {
    return res.status(413).json({
      success: false,
      message: 'Request payload too large',
    });
  }
  
  next();
};

/**
 * SQL Injection protection - additional layer
 */
const sqlInjectionProtection = (req, res, next) => {
  const sqlPatterns = [
    /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION)\b)/gi,
    /(;|\-\-|\/\*|\*\/)/g,
  ];

  const checkForSqlInjection = (obj) => {
    if (typeof obj === 'string') {
      return sqlPatterns.some((pattern) => pattern.test(obj));
    }
    
    if (typeof obj === 'object' && obj !== null) {
      return Object.values(obj).some(checkForSqlInjection);
    }
    
    return false;
  };

  // Check query parameters, body, and params
  const hasInjection = 
    checkForSqlInjection(req.query) ||
    checkForSqlInjection(req.body) ||
    checkForSqlInjection(req.params);

  if (hasInjection) {
    return res.status(400).json({
      success: false,
      message: 'Invalid input detected',
    });
  }

  next();
};

/**
 * NoSQL Injection protection
 */
const noSqlInjectionProtection = (req, res, next) => {
  const checkForNoSqlInjection = (obj) => {
    if (typeof obj === 'object' && obj !== null) {
      for (const key in obj) {
        if (key.startsWith('$')) {
          return true;
        }
        if (checkForNoSqlInjection(obj[key])) {
          return true;
        }
      }
    }
    return false;
  };

  const hasInjection = 
    checkForNoSqlInjection(req.query) ||
    checkForNoSqlInjection(req.body) ||
    checkForNoSqlInjection(req.params);

  if (hasInjection) {
    return res.status(400).json({
      success: false,
      message: 'Invalid input detected',
    });
  }

  next();
};

/**
 * XSS Protection middleware
 * Detects common XSS attack patterns in user input
 * Note: This is a basic implementation. For production, consider using helmet and xss libraries
 */
const xssProtection = (req, res, next) => {
  // Detect dangerous characters and patterns
  const checkForXss = (obj) => {
    if (typeof obj === 'string') {
      // Check for script tags, event handlers, and javascript: protocol
      const dangerousPatterns = [
        /<script[\s\S]*?>/i,        // Opening script tag with any attributes
        /<\/script>/i,               // Closing script tag
        /javascript\s*:/i,           // JavaScript protocol
        /on\w+\s*=/i,                // Event handlers like onclick=
        /<iframe/i,                  // iframes
        /<object/i,                  // object tags
        /<embed/i,                   // embed tags
      ];
      
      return dangerousPatterns.some((pattern) => pattern.test(obj));
    }
    
    if (typeof obj === 'object' && obj !== null) {
      return Object.values(obj).some(checkForXss);
    }
    
    return false;
  };

  const hasXss = 
    checkForXss(req.query) ||
    checkForXss(req.body) ||
    checkForXss(req.params);

  if (hasXss) {
    return res.status(400).json({
      success: false,
      message: 'Invalid input detected - potential XSS attack',
    });
  }

  next();
};

module.exports = {
  apiLimiter,
  authLimiter,
  paymentLimiter,
  otpLimiter,
  requestSizeLimiter,
  sqlInjectionProtection,
  noSqlInjectionProtection,
  xssProtection,
};
