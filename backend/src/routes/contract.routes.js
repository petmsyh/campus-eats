const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { prisma } = require('../config/prisma');
const logger = require('../utils/logger');

// @route   POST /api/v1/contracts
// @desc    Create a new contract
// @access  Private
router.post('/', auth, async (req, res) => {
  try {
    const { loungeId, totalAmount, durationDays } = req.body;

    if (!totalAmount || totalAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount'
      });
    }

    const duration = durationDays || 30; // Default 30 days
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + duration);

    // Check if active contract exists
    const existingContract = await prisma.contract.findFirst({
      where: {
        userId: req.user.id,
        loungeId,
        isActive: true,
        isExpired: false
      }
    });

    if (existingContract) {
      return res.status(400).json({
        success: false,
        message: 'You already have an active contract with this lounge'
      });
    }

    // Create payment and contract in transaction
    const result = await prisma.$transaction(async (tx) => {
      const payment = await tx.payment.create({
        data: {
          userId: req.user.id,
          amount: totalAmount,
          type: 'CONTRACT',
          method: 'chapa',
          status: 'PENDING'
        }
      });

      const contract = await tx.contract.create({
        data: {
          userId: req.user.id,
          loungeId,
          totalAmount,
          remainingBalance: totalAmount,
          expiresAt,
          paymentId: payment.id
        },
        include: {
          lounge: { select: { name: true, logo: true } }
        }
      });

      // Update payment with contract ID
      await tx.payment.update({
        where: { id: payment.id },
        data: { contractId: contract.id }
      });

      return { contract, payment };
    });

    res.status(201).json({
      success: true,
      message: 'Contract created successfully. Complete payment to activate.',
      data: {
        contract: result.contract,
        payment: {
          id: result.payment.id,
          amount: result.payment.amount,
          status: result.payment.status
        }
      }
    });
  } catch (error) {
    logger.error('Create contract error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/contracts
// @desc    Get user's contracts
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { loungeId, status } = req.query;

    const where = { userId: req.user.id };
    if (loungeId) where.loungeId = loungeId;
    if (status === 'active') {
      where.isActive = true;
      where.isExpired = false;
    } else if (status === 'expired') {
      where.isExpired = true;
    }

    const contracts = await prisma.contract.findMany({
      where,
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

// @route   GET /api/v1/contracts/:id
// @desc    Get contract by ID
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const contract = await prisma.contract.findUnique({
      where: { id: req.params.id },
      include: {
        lounge: { select: { name: true, logo: true, opening: true, closing: true } },
        payment: true
      }
    });

    if (!contract) {
      return res.status(404).json({
        success: false,
        message: 'Contract not found'
      });
    }

    // Check ownership
    if (contract.userId !== req.user.id && req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this contract'
      });
    }

    res.status(200).json({
      success: true,
      data: contract
    });
  } catch (error) {
    logger.error('Get contract error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/contracts/:id/renew
// @desc    Renew a contract
// @access  Private
router.post('/:id/renew', auth, async (req, res) => {
  try {
    const { amount, durationDays } = req.body;

    const contract = await prisma.contract.findUnique({
      where: { id: req.params.id }
    });

    if (!contract) {
      return res.status(404).json({
        success: false,
        message: 'Contract not found'
      });
    }

    // Check ownership
    if (contract.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to renew this contract'
      });
    }

    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount'
      });
    }

    // Create payment and update contract in transaction
    const result = await prisma.$transaction(async (tx) => {
      const payment = await tx.payment.create({
        data: {
          userId: req.user.id,
          amount,
          type: 'CONTRACT',
          method: 'chapa',
          status: 'PENDING',
          contractId: contract.id
        }
      });

      // Extend expiry date
      const duration = durationDays || 30;
      const newExpiryDate = new Date(contract.expiresAt);
      newExpiryDate.setDate(newExpiryDate.getDate() + duration);

      const updatedContract = await tx.contract.update({
        where: { id: req.params.id },
        data: {
          totalAmount: contract.totalAmount + amount,
          remainingBalance: contract.remainingBalance + amount,
          renewalCount: contract.renewalCount + 1,
          isExpired: false,
          isActive: true,
          expiresAt: newExpiryDate
        }
      });

      return { contract: updatedContract, payment };
    });

    res.status(200).json({
      success: true,
      message: 'Contract renewal initiated. Complete payment to activate.',
      data: {
        contract: result.contract,
        payment: {
          id: result.payment.id,
          amount: result.payment.amount,
          status: result.payment.status
        }
      }
    });
  } catch (error) {
    logger.error('Renew contract error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/contracts/lounge/:loungeId
// @desc    Get user's contract with specific lounge
// @access  Private
router.get('/lounge/:loungeId', auth, async (req, res) => {
  try {
    const contract = await prisma.contract.findFirst({
      where: {
        userId: req.user.id,
        loungeId: req.params.loungeId,
        isActive: true,
        isExpired: false
      },
      include: {
        lounge: { select: { name: true, logo: true } }
      }
    });

    if (!contract) {
      return res.status(404).json({
        success: false,
        message: 'No active contract found with this lounge'
      });
    }

    res.status(200).json({
      success: true,
      data: contract
    });
  } catch (error) {
    logger.error('Get lounge contract error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
