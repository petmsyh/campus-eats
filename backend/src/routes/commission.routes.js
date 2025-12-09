const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { prisma } = require('../config/prisma');
const logger = require('../utils/logger');

// @route   GET /api/v1/commissions
// @desc    Get commissions (admin or lounge owner)
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { loungeId, status, page = 1, limit = 10 } = req.query;

    let where = {};

    if (req.user.role === 'LOUNGE') {
      // Get lounges owned by this user
      const lounges = await prisma.lounge.findMany({
        where: { ownerId: req.user.id },
        select: { id: true }
      });
      const loungeIds = lounges.map(l => l.id);
      where.loungeId = { in: loungeIds };
    } else if (req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    if (loungeId && req.user.role === 'ADMIN') where.loungeId = loungeId;
    if (status) where.status = status.toUpperCase();

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const take = parseInt(limit);

    const [commissions, total] = await Promise.all([
      prisma.commission.findMany({
        where,
        include: {
          lounge: { select: { name: true } },
          order: { select: { id: true, createdAt: true } }
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take
      }),
      prisma.commission.count({ where })
    ]);

    res.status(200).json({
      success: true,
      data: commissions,
      pagination: {
        total,
        page: parseInt(page),
        pages: Math.ceil(total / take)
      }
    });
  } catch (error) {
    logger.error('Get commissions error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/commissions/stats
// @desc    Get commission statistics
// @access  Private (Admin or Lounge owner)
router.get('/stats', auth, async (req, res) => {
  try {
    let where = {};

    if (req.user.role === 'LOUNGE') {
      const lounges = await prisma.lounge.findMany({
        where: { ownerId: req.user.id },
        select: { id: true }
      });
      const loungeIds = lounges.map(l => l.id);
      where.loungeId = { in: loungeIds };
    } else if (req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    const [total, pending, paid] = await Promise.all([
      prisma.commission.aggregate({
        where,
        _sum: { amount: true }
      }),
      prisma.commission.aggregate({
        where: { ...where, status: 'PENDING' },
        _sum: { amount: true }
      }),
      prisma.commission.aggregate({
        where: { ...where, status: 'PAID' },
        _sum: { amount: true }
      })
    ]);

    res.status(200).json({
      success: true,
      data: {
        total: total._sum.amount || 0,
        pending: pending._sum.amount || 0,
        paid: paid._sum.amount || 0
      }
    });
  } catch (error) {
    logger.error('Get commission stats error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   PUT /api/v1/commissions/:id/status
// @desc    Update commission status (mark as paid)
// @access  Private (Admin only)
router.put('/:id/status', auth, authorize('ADMIN'), async (req, res) => {
  try {
    const { status } = req.body;

    const validStatuses = ['PENDING', 'PAID', 'CANCELLED'];
    if (!validStatuses.includes(status.toUpperCase())) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status. Must be one of: PENDING, PAID, CANCELLED'
      });
    }

    const updateData = { status: status.toUpperCase() };
    if (status.toUpperCase() === 'PAID') {
      updateData.paidAt = new Date();
    }

    const commission = await prisma.commission.update({
      where: { id: req.params.id },
      data: updateData
    });

    res.status(200).json({
      success: true,
      message: 'Commission status updated successfully',
      data: commission
    });
  } catch (error) {
    logger.error('Update commission status error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/commissions/:id
// @desc    Get commission by ID
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const commission = await prisma.commission.findUnique({
      where: { id: req.params.id },
      include: {
        lounge: true,
        order: true
      }
    });

    if (!commission) {
      return res.status(404).json({
        success: false,
        message: 'Commission not found'
      });
    }

    // Check authorization
    if (req.user.role === 'LOUNGE') {
      const lounge = await prisma.lounge.findUnique({
        where: { id: commission.loungeId }
      });
      
      if (!lounge || lounge.ownerId !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized'
        });
      }
    } else if (req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    res.status(200).json({
      success: true,
      data: commission
    });
  } catch (error) {
    logger.error('Get commission error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
