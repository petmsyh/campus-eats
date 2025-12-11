const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { orderValidations, validate, commonValidations } = require('../middleware/validator');
const {
  createOrder,
  getOrders,
  getOrderById,
  updateOrderStatus,
  verifyQrCode,
} = require('../controllers/order.controller');

// @route   POST /api/v1/orders
// @desc    Create a new order
// @access  Private
router.post('/', auth, orderValidations.create, validate, createOrder);

// @route   GET /api/v1/orders
// @desc    Get orders (user's own or lounge's orders)
// @access  Private
router.get('/', auth, commonValidations.pagination, validate, getOrders);

// @route   GET /api/v1/orders/:id
// @desc    Get order by ID
// @access  Private
router.get('/:id', auth, commonValidations.id, validate, getOrderById);

// @route   PUT /api/v1/orders/:id/status
// @desc    Update order status
// @access  Private (Lounge owner)
router.put(
  '/:id/status',
  auth,
  authorize('LOUNGE', 'ADMIN'),
  orderValidations.updateStatus,
  validate,
  updateOrderStatus
);

// @route   POST /api/v1/orders/verify-qr
// @desc    Verify QR code and mark order as delivered
// @access  Private (Lounge owner)
router.post(
  '/verify-qr',
  auth,
  authorize('LOUNGE', 'ADMIN'),
  orderValidations.verifyQr,
  validate,
  verifyQrCode
);

module.exports = router;
