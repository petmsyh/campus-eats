const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { prisma } = require('../config/prisma');
const { generateToken } = require('../utils/jwt');
const { generateOTP, getOTPExpiry, verifyOTP } = require('../utils/otp');
const { hashPassword, comparePassword, sanitizeUser } = require('../utils/userHelpers');
const logger = require('../utils/logger');

// @route   POST /api/v1/auth/register
// @desc    Register a new user
// @access  Public
router.post('/register', async (req, res) => {
  try {
    const { name, phone, email, password, universityId, campusId, role } = req.body;
    const normalizedRole = role ? role.toUpperCase() : 'USER';

    // Check if user exists
    const existingUser = await prisma.user.findUnique({ 
      where: { phone }
    });
    
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this phone number'
      });
    }

    // Generate OTP
    const otpCode = generateOTP();
    const otpExpiry = getOTPExpiry();

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user
    const user = await prisma.user.create({
      data: {
        name,
        phone,
        email: email || null,
        password: hashedPassword,
        universityId,
        campusId,
        role: normalizedRole,
        otpCode,
        otpExpiresAt: otpExpiry
      }
    });

    if (normalizedRole === 'LOUNGE') {
      await prisma.lounge.create({
        data: {
          name: `${name}'s Lounge`,
          owner: {
            connect: { id: user.id }
          },
          university: {
            connect: { id: universityId }
          },
          campus: {
            connect: { id: campusId }
          },
          description: `${name}'s lounge profile is pending setup`,
          accountNumber: null,
          bankName: null,
          accountHolderName: null,
          opening: null,
          closing: null,
          isApproved: false,
          isActive: true
        }
      });
    }

    // TODO: Send OTP via SMS service (e.g., Africa's Talking, Twilio)
    // For development, OTP can be retrieved from database or logs
    // SECURITY: Never log OTP in production - implement SMS service
    if (process.env.NODE_ENV !== 'production') {
      logger.info(`Development Mode - OTP for ${phone}: ${otpCode}`);
    }
    // In production, SMS service should be integrated and no logging should occur

    res.status(201).json({
      success: true,
      message: 'User registered successfully. Please verify OTP.',
      data: {
        userId: user.id,
        phone: user.phone,
        // In development, send OTP in response
        ...(process.env.NODE_ENV === 'development' && { otp: otpCode })
      }
    });
  } catch (error) {
    logger.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/auth/verify-otp
// @desc    Verify OTP and activate account
// @access  Public
router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;

    const user = await prisma.user.findUnique({ 
      where: { phone }
    });
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Verify OTP
    const verification = verifyOTP(user.otpCode, otp, user.otpExpiresAt);
    if (!verification.valid) {
      return res.status(400).json({
        success: false,
        message: verification.message
      });
    }

    // Activate account
    const updatedUser = await prisma.user.update({
      where: { id: user.id },
      data: {
        isVerified: true,
        otpCode: null,
        otpExpiresAt: null
      }
    });

    // Generate token
    const token = generateToken(updatedUser.id);

    res.status(200).json({
      success: true,
      message: 'Account verified successfully',
      data: {
        token,
        user: sanitizeUser(updatedUser)
      }
    });
  } catch (error) {
    logger.error('OTP verification error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/auth/login
// @desc    Login user
// @access  Public
router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;

    // Check if user exists
    const user = await prisma.user.findUnique({ 
      where: { phone }
    });
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check password
    const isMatch = await comparePassword(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    if (!user.isVerified) {
      return res.status(401).json({
        success: false,
        message: 'Please verify your account first'
      });
    }

    if (!user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Your account has been deactivated'
      });
    }

    // Update last login
    const updatedUser = await prisma.user.update({
      where: { id: user.id },
      data: { lastLogin: new Date() }
    });

    // Generate token
    const token = generateToken(updatedUser.id);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: sanitizeUser(updatedUser)
      }
    });
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/auth/resend-otp
// @desc    Resend OTP
// @access  Public
router.post('/resend-otp', async (req, res) => {
  try {
    const { phone } = req.body;

    const user = await prisma.user.findUnique({ 
      where: { phone }
    });
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    if (user.isVerified) {
      return res.status(400).json({
        success: false,
        message: 'Account already verified'
      });
    }

    // Generate new OTP
    const otpCode = generateOTP();
    const otpExpiry = getOTPExpiry();

    await prisma.user.update({
      where: { id: user.id },
      data: {
        otpCode,
        otpExpiresAt: otpExpiry
      }
    });

    // TODO: Send OTP via SMS service (e.g., Africa's Talking, Twilio)
    // SECURITY: Never log OTP in production - implement SMS service
    if (process.env.NODE_ENV !== 'production') {
      logger.info(`Development Mode - OTP for ${phone}: ${otpCode}`);
    }
    // In production, SMS service should be integrated and no logging should occur

    res.status(200).json({
      success: true,
      message: 'OTP sent successfully',
      ...(process.env.NODE_ENV === 'development' && { otp: otpCode })
    });
  } catch (error) {
    logger.error('Resend OTP error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/auth/me
// @desc    Get current user
// @access  Private
router.get('/me', auth, async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      data: req.user
    });
  } catch (error) {
    logger.error('Get me error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
