const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { prisma } = require('../config/prisma');
const { generateQRData, generateQRCode, verifyQRCode } = require('../utils/qrcode');
const notificationService = require('../services/notification.service');
const logger = require('../utils/logger');

// @route   POST /api/v1/orders
// @desc    Create a new order
// @access  Private
router.post('/', auth, async (req, res) => {
  try {
    const { loungeId, items, paymentMethod, contractId } = req.body;

    // Validate items
    if (!items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Order must contain at least one item'
      });
    }

    // Fetch food items and calculate total
    let totalPrice = 0;
    const orderItems = [];

    for (const item of items) {
      const food = await prisma.food.findUnique({
        where: { id: item.foodId }
      });

      if (!food) {
        return res.status(404).json({
          success: false,
          message: `Food item ${item.foodId} not found`
        });
      }

      if (!food.isAvailable) {
        return res.status(400).json({
          success: false,
          message: `${food.name} is not available`
        });
      }

      const subtotal = food.price * item.quantity;
      totalPrice += subtotal;

      orderItems.push({
        foodId: food.id,
        name: food.name,
        quantity: item.quantity,
        price: food.price,
        subtotal,
        estimatedTime: food.estimatedTime
      });
    }

    // Calculate commission
    const commissionRate = parseFloat(process.env.SYSTEM_COMMISSION_RATE) || 0.05;
    const commission = totalPrice * commissionRate;

    // Handle payment method
    let payment;
    if (paymentMethod === 'contract') {
      // Validate contract
      const contract = await prisma.contract.findFirst({
        where: {
          id: contractId,
          userId: req.user.id,
          loungeId,
          isActive: true,
          isExpired: false
        }
      });

      if (!contract) {
        return res.status(400).json({
          success: false,
          message: 'Valid contract not found for this lounge'
        });
      }

      if (contract.remainingBalance < totalPrice) {
        return res.status(400).json({
          success: false,
          message: 'Insufficient contract balance'
        });
      }

      // Deduct from contract and create payment in a transaction
      const result = await prisma.$transaction(async (tx) => {
        await tx.contract.update({
          where: { id: contract.id },
          data: {
            remainingBalance: contract.remainingBalance - totalPrice
          }
        });

        const payment = await tx.payment.create({
          data: {
            userId: req.user.id,
            amount: totalPrice,
            type: 'ORDER',
            method: 'contract-wallet',
            status: 'COMPLETED',
            contractId: contract.id,
            commission
          }
        });

        return payment;
      });

      payment = result;
    } else if (paymentMethod === 'chapa') {
      // Payment will be handled separately via Chapa
      payment = await prisma.payment.create({
        data: {
          userId: req.user.id,
          amount: totalPrice,
          type: 'ORDER',
          method: 'chapa',
          status: 'PENDING',
          commission
        }
      });
    } else {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment method'
      });
    }

    // Create order with items
    const orderData = {
      userId: req.user.id,
      loungeId,
      totalPrice,
      paymentMethod: paymentMethod.toUpperCase(),
      paymentId: payment.id,
      contractId: paymentMethod === 'contract' ? contractId : null,
      commission,
      items: {
        create: orderItems.map(item => ({
          foodId: item.foodId,
          name: item.name,
          quantity: item.quantity,
          price: item.price,
          subtotal: item.subtotal,
          estimatedTime: item.estimatedTime
        }))
      }
    };

    const order = await prisma.order.create({
      data: orderData,
      include: {
        items: true,
        lounge: { select: { name: true, logo: true } }
      }
    });

    // Generate QR code
    const qrData = generateQRData(order.id);
    const qrCodeImage = await generateQRCode(qrData);

    // Update order with QR code
    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: {
        qrCode: qrData,
        qrCodeImage
      },
      include: {
        items: true,
        lounge: { select: { name: true, logo: true } }
      }
    });

    // Update payment with orderId
    await prisma.payment.update({
      where: { id: payment.id },
      data: { orderId: order.id }
    });

    // Create commission record
    await prisma.commission.create({
      data: {
        orderId: order.id,
        loungeId,
        amount: commission,
        rate: commissionRate,
        orderAmount: totalPrice
      }
    });

    // Send notification to user
    if (req.user.fcmToken) {
      const notification = notificationService.orderStatusNotification('preparing', order.id);
      await notificationService.sendNotification(req.user.fcmToken, notification, {
        orderId: order.id,
        type: 'order_status'
      });
    }

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: updatedOrder
    });
  } catch (error) {
    logger.error('Create order error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/orders
// @desc    Get orders (user's own or lounge's orders)
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const { status, page = 1, limit = 10 } = req.query;

    let where = {};

    if (req.user.role === 'USER') {
      where.userId = req.user.id;
    } else if (req.user.role === 'LOUNGE') {
      // Find lounges owned by this user
      const lounges = await prisma.lounge.findMany({
        where: { ownerId: req.user.id },
        select: { id: true }
      });
      const loungeIds = lounges.map(l => l.id);
      where.loungeId = { in: loungeIds };
    }

    if (status) where.status = status.toUpperCase();

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const take = parseInt(limit);

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where,
        include: {
          user: { select: { name: true, phone: true } },
          lounge: { select: { name: true, logo: true } }
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

// @route   GET /api/v1/orders/:id
// @desc    Get order by ID
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const order = await prisma.order.findUnique({
      where: { id: req.params.id },
      include: {
        user: { select: { name: true, phone: true } },
        lounge: { select: { name: true, logo: true, opening: true, closing: true } },
        items: {
          include: {
            food: true
          }
        }
      }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Check authorization
    const lounge = await prisma.lounge.findUnique({
      where: { id: order.loungeId }
    });
    
    if (
      req.user.role !== 'ADMIN' &&
      order.userId !== req.user.id &&
      (!lounge || lounge.ownerId !== req.user.id)
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this order'
      });
    }

    res.status(200).json({
      success: true,
      data: order
    });
  } catch (error) {
    logger.error('Get order error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   PUT /api/v1/orders/:id/status
// @desc    Update order status
// @access  Private (Lounge owner)
router.put('/:id/status', auth, authorize('LOUNGE', 'ADMIN'), async (req, res) => {
  try {
    const { status } = req.body;

    const validStatuses = ['PENDING', 'PREPARING', 'READY', 'DELIVERED', 'CANCELLED'];
    const statusUpper = status.toUpperCase();
    
    if (!validStatuses.includes(statusUpper)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }

    const order = await prisma.order.findUnique({
      where: { id: req.params.id },
      include: { lounge: true }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Check authorization
    if (req.user.role !== 'ADMIN' && order.lounge.ownerId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this order'
      });
    }

    const updateData = { status: statusUpper };
    if (statusUpper === 'DELIVERED') {
      updateData.deliveredAt = new Date();
    }

    const updatedOrder = await prisma.order.update({
      where: { id: req.params.id },
      data: updateData
    });

    // Send notification to user
    const user = await prisma.user.findUnique({
      where: { id: order.userId }
    });
    
    if (user && user.fcmToken) {
      const notification = notificationService.orderStatusNotification(statusUpper, order.id);
      await notificationService.sendNotification(user.fcmToken, notification, {
        orderId: order.id,
        type: 'order_status',
        status: statusUpper
      });
    }

    res.status(200).json({
      success: true,
      message: 'Order status updated successfully',
      data: updatedOrder
    });
  } catch (error) {
    logger.error('Update order status error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/orders/verify-qr
// @desc    Verify QR code and mark order as delivered
// @access  Private (Lounge owner)
router.post('/verify-qr', auth, authorize('LOUNGE', 'ADMIN'), async (req, res) => {
  try {
    const { qrCode } = req.body;

    // Verify QR code format
    const verification = verifyQRCode(qrCode);
    if (!verification.valid) {
      return res.status(400).json({
        success: false,
        message: 'Invalid QR code'
      });
    }

    // Find order
    const order = await prisma.order.findFirst({
      where: { qrCode },
      include: {
        lounge: true,
        user: true
      }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Check authorization
    if (req.user.role !== 'ADMIN' && order.lounge.ownerId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to verify this order'
      });
    }

    if (order.status === 'DELIVERED') {
      return res.status(400).json({
        success: false,
        message: 'Order already delivered'
      });
    }

    // Update order status
    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: {
        status: 'DELIVERED',
        deliveredAt: new Date()
      }
    });

    // Send notification to user
    if (order.user.fcmToken) {
      const notification = notificationService.orderStatusNotification('DELIVERED', order.id);
      await notificationService.sendNotification(order.user.fcmToken, notification, {
        orderId: order.id,
        type: 'order_status',
        status: 'DELIVERED'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Order verified and marked as delivered',
      data: updatedOrder
    });
  } catch (error) {
    logger.error('Verify QR error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
