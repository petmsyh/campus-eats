const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { prisma } = require('../config/prisma');
const logger = require('../utils/logger');

// @route   GET /api/v1/foods
// @desc    Get all foods (with filters)
// @access  Public
router.get('/', async (req, res) => {
  try {
    const { loungeId, category, search, available } = req.query;

    const where = {};
    
    if (loungeId) where.loungeId = loungeId;
    if (category) where.category = category.toUpperCase();
    if (available !== undefined) where.isAvailable = available === 'true';
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } }
      ];
    }

    const foods = await prisma.food.findMany({
      where,
      include: {
        lounge: { select: { name: true, logo: true } }
      },
      orderBy: { ratingAverage: 'desc' }
    });

    res.status(200).json({
      success: true,
      data: foods
    });
  } catch (error) {
    logger.error('Get foods error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/foods/:id
// @desc    Get food by ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const food = await prisma.food.findUnique({
      where: { id: req.params.id },
      include: {
        lounge: { select: { name: true, logo: true, opening: true, closing: true } }
      }
    });

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found'
      });
    }

    res.status(200).json({
      success: true,
      data: food
    });
  } catch (error) {
    logger.error('Get food error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/foods
// @desc    Create a food item
// @access  Private (Lounge owner)
router.post('/', auth, authorize('LOUNGE', 'ADMIN'), async (req, res) => {
  try {
    const {
      loungeId,
      name,
      description,
      category,
      price,
      image,
      estimatedTime,
      ingredients,
      allergens,
      isVegetarian,
      spicyLevel
    } = req.body;

    // Verify lounge ownership
    if (req.user.role !== 'ADMIN') {
      const lounge = await prisma.lounge.findUnique({
        where: { id: loungeId }
      });
      
      if (!lounge || lounge.ownerId !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized to add food to this lounge'
        });
      }
    }

    const food = await prisma.food.create({
      data: {
        loungeId,
        name,
        description,
        category: category.toUpperCase(),
        price,
        image,
        estimatedTime,
        ingredients: ingredients || [],
        allergens: allergens || [],
        isVegetarian: isVegetarian || false,
        spicyLevel: spicyLevel ? spicyLevel.toUpperCase() : 'NONE'
      }
    });

    res.status(201).json({
      success: true,
      message: 'Food item created successfully',
      data: food
    });
  } catch (error) {
    logger.error('Create food error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   PUT /api/v1/foods/:id
// @desc    Update food item
// @access  Private (Lounge owner)
router.put('/:id', auth, authorize('LOUNGE', 'ADMIN'), async (req, res) => {
  try {
    const food = await prisma.food.findUnique({
      where: { id: req.params.id },
      include: { lounge: true }
    });

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found'
      });
    }

    // Check ownership
    if (req.user.role !== 'ADMIN' && food.lounge.ownerId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this food item'
      });
    }

    const updateData = {};
    const allowedFields = [
      'name', 'description', 'category', 'price', 'image',
      'estimatedTime', 'isAvailable', 'ingredients', 'allergens',
      'isVegetarian', 'spicyLevel'
    ];

    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        if (field === 'category' || field === 'spicyLevel') {
          updateData[field] = req.body[field].toUpperCase();
        } else {
          updateData[field] = req.body[field];
        }
      }
    });

    const updatedFood = await prisma.food.update({
      where: { id: req.params.id },
      data: updateData
    });

    res.status(200).json({
      success: true,
      message: 'Food item updated successfully',
      data: updatedFood
    });
  } catch (error) {
    logger.error('Update food error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   DELETE /api/v1/foods/:id
// @desc    Delete food item
// @access  Private (Lounge owner)
router.delete('/:id', auth, authorize('LOUNGE', 'ADMIN'), async (req, res) => {
  try {
    const food = await prisma.food.findUnique({
      where: { id: req.params.id },
      include: { lounge: true }
    });

    if (!food) {
      return res.status(404).json({
        success: false,
        message: 'Food item not found'
      });
    }

    // Check ownership
    if (req.user.role !== 'ADMIN' && food.lounge.ownerId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this food item'
      });
    }

    await prisma.food.delete({
      where: { id: req.params.id }
    });

    res.status(200).json({
      success: true,
      message: 'Food item deleted successfully'
    });
  } catch (error) {
    logger.error('Delete food error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
