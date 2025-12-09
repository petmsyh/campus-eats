const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { prisma } = require('../config/prisma');
const logger = require('../utils/logger');

// @route   GET /api/v1/users/profile
// @desc    Get user profile
// @access  Private
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: {
        university: { select: { name: true, code: true } },
        campus: { select: { name: true } }
      }
    });

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    logger.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   PUT /api/v1/users/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', auth, async (req, res) => {
  try {
    const { name, email, fcmToken } = req.body;

    const updateData = { name };
    if (email !== undefined) updateData.email = email;
    if (fcmToken) updateData.fcmToken = fcmToken;

    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: updateData
    });

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: user
    });
  } catch (error) {
    logger.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/users/wallet
// @desc    Get wallet balance
// @access  Private
router.get('/wallet', auth, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: { walletBalance: true }
    });

    res.status(200).json({
      success: true,
      data: {
        balance: user.walletBalance
      }
    });
  } catch (error) {
    logger.error('Get wallet error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/users/contracts
// @desc    Get user contracts
// @access  Private
router.get('/contracts', auth, async (req, res) => {
  try {
    const contracts = await prisma.contract.findMany({
      where: { userId: req.user.id },
      include: {
        lounge: { select: { name: true, logo: true } }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.status(200).json({
      success: true,
      data: contracts
    });
  } catch (error) {
    logger.error('Get contracts error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/users/orders
// @desc    Get user orders
// @access  Private
router.get('/orders', auth, async (req, res) => {
  try {
    const { status, page = 1, limit = 10 } = req.query;

    const where = { userId: req.user.id };
    if (status) where.status = status.toUpperCase();

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const take = parseInt(limit);

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where,
        include: {
          lounge: { select: { name: true, logo: true } },
          items: {
            include: {
              food: { select: { name: true, image: true } }
            }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take
      }),
      prisma.order.count({ where })
    ]);

    res.status(200).json({
      success: true,
      data: orders,
      pagination: {
        total,
        page: parseInt(page),
        pages: Math.ceil(total / take)
      }
    });
  } catch (error) {
    logger.error('Get orders error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
