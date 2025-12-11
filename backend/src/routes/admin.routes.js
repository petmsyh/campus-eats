const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { validate, commonValidations } = require('../middleware/validator');
const {
  getSystemStats,
  getAllUsers,
  updateUser,
  getAllLounges,
  approveLounge,
  createUniversity,
  getAllUniversities,
  createCampus,
  getAllCampuses,
  getAllOrders,
  getAllCommissions,
  getAllPayments,
} = require('../controllers/admin.controller');

// @route   GET /api/v1/admin/stats
// @desc    Get system statistics
// @access  Private (Admin)
router.get('/stats', auth, authorize('ADMIN'), getSystemStats);

// @route   GET /api/v1/admin/users
// @desc    Get all users
// @access  Private (Admin)
router.get('/users', auth, authorize('ADMIN'), commonValidations.pagination, validate, getAllUsers);

// @route   PUT /api/v1/admin/users/:id
// @desc    Update user (activate/deactivate)
// @access  Private (Admin)
router.put('/users/:id', auth, authorize('ADMIN'), commonValidations.id, validate, updateUser);

// @route   GET /api/v1/admin/lounges
// @desc    Get all lounges (including pending approval)
// @access  Private (Admin)
router.get('/lounges', auth, authorize('ADMIN'), commonValidations.pagination, validate, getAllLounges);

// @route   PUT /api/v1/admin/lounges/:id/approve
// @desc    Approve or reject lounge
// @access  Private (Admin)
router.put('/lounges/:id/approve', auth, authorize('ADMIN'), commonValidations.id, validate, approveLounge);

// @route   POST /api/v1/admin/universities
// @desc    Create university
// @access  Private (Admin)
router.post('/universities', auth, authorize('ADMIN'), createUniversity);

// @route   GET /api/v1/admin/universities
// @desc    Get all universities
// @access  Private (Admin)
router.get('/universities', auth, authorize('ADMIN'), getAllUniversities);

// @route   POST /api/v1/admin/campuses
// @desc    Create campus
// @access  Private (Admin)
router.post('/campuses', auth, authorize('ADMIN'), createCampus);

// @route   GET /api/v1/admin/campuses
// @desc    Get all campuses
// @access  Private (Admin)
router.get('/campuses', auth, authorize('ADMIN'), getAllCampuses);

// @route   GET /api/v1/admin/orders
// @desc    Get all orders (admin overview)
// @access  Private (Admin)
router.get('/orders', auth, authorize('ADMIN'), commonValidations.pagination, validate, getAllOrders);

// @route   GET /api/v1/admin/commissions
// @desc    Get all commissions (admin overview)
// @access  Private (Admin)
router.get('/commissions', auth, authorize('ADMIN'), commonValidations.pagination, validate, getAllCommissions);

// @route   GET /api/v1/admin/payments
// @desc    Get all payments (admin overview)
// @access  Private (Admin)
router.get('/payments', auth, authorize('ADMIN'), commonValidations.pagination, validate, getAllPayments);

module.exports = router;
