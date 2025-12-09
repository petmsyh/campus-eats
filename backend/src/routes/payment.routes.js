const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { prisma } = require('../config/prisma');
const chapaService = require('../services/chapa.service');
const logger = require('../utils/logger');

// @route   POST /api/v1/payments/initialize
// @desc    Initialize Chapa payment
// @access  Private
router.post('/initialize', auth, async (req, res) => {
  try {
    const { paymentId } = req.body;

    const payment = await prisma.payment.findUnique({
      where: { id: paymentId }
    });

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    if (payment.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    if (payment.status !== 'PENDING') {
      return res.status(400).json({
        success: false,
        message: 'Payment already processed'
      });
    }

    const user = await prisma.user.findUnique({
      where: { id: req.user.id }
    });

    // Initialize Chapa payment
    const chapaResponse = await chapaService.initializePayment({
      amount: payment.amount,
      email: user.email || `${user.phone}@campuseats.et`,
      first_name: user.name.split(' ')[0],
      last_name: user.name.split(' ').slice(1).join(' ') || user.name,
      tx_ref: payment.id,
      callback_url: process.env.CHAPA_CALLBACK_URL,
      return_url: process.env.CHAPA_CALLBACK_URL,
      customization: {
        title: 'Campus Eats Payment',
        description: `Payment for ${payment.type.toLowerCase()}`
      }
    });

    // Update payment with Chapa reference
    await prisma.payment.update({
      where: { id: payment.id },
      data: {
        chapaReference: chapaResponse.data.tx_ref,
        metadata: chapaResponse.data
      }
    });

    res.status(200).json({
      success: true,
      data: {
        checkout_url: chapaResponse.data.checkout_url
      }
    });
  } catch (error) {
    logger.error('Initialize payment error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/payments/webhook
// @desc    Chapa payment webhook
// @access  Public
router.post('/webhook', async (req, res) => {
  try {
    const { tx_ref, status, transaction_id } = req.body;

    logger.info('Chapa webhook received:', req.body);

    const payment = await prisma.payment.findFirst({
      where: { chapaReference: tx_ref }
    });

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    if (status === 'success') {
      await prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: 'COMPLETED',
          chapaTransactionId: transaction_id
        }
      });

      // If it's a contract payment, activate the contract
      if (payment.contractId) {
        await prisma.contract.update({
          where: { id: payment.contractId },
          data: { isActive: true }
        });
      }
    } else {
      await prisma.payment.update({
        where: { id: payment.id },
        data: { status: 'FAILED' }
      });
    }

    res.status(200).json({ success: true });
  } catch (error) {
    logger.error('Webhook error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/payments
// @desc    Get user's payments
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { type, status, page = 1, limit = 10 } = req.query;

    const where = { userId: req.user.id };
    if (type) where.type = type.toUpperCase();
    if (status) where.status = status.toUpperCase();

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const take = parseInt(limit);

    const [payments, total] = await Promise.all([
      prisma.payment.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take
      }),
      prisma.payment.count({ where })
    ]);

    res.status(200).json({
      success: true,
      data: payments,
      pagination: {
        total,
        page: parseInt(page),
        pages: Math.ceil(total / take)
      }
    });
  } catch (error) {
    logger.error('Get payments error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/payments/:id
// @desc    Get payment by ID
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const payment = await prisma.payment.findUnique({
      where: { id: req.params.id }
    });

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    if (payment.userId !== req.user.id && req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    res.status(200).json({
      success: true,
      data: payment
    });
  } catch (error) {
    logger.error('Get payment error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
