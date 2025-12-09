const express = require('express');
const router = express.Router();
const { prisma } = require('../config/prisma');
const logger = require('../utils/logger');

// @route   GET /api/v1/reference/universities
// @desc    Public list of universities (with basic campus info)
// @access  Public
router.get('/universities', async (req, res) => {
  try {
    const universities = await prisma.university.findMany({
      include: {
        campuses: {
          select: {
            id: true,
            name: true
          },
          orderBy: { name: 'asc' }
        }
      },
      orderBy: { name: 'asc' }
    });

    res.status(200).json({
      success: true,
      data: universities.map((uni) => ({
        id: uni.id,
        name: uni.name,
        code: uni.code,
        city: uni.city,
        region: uni.region,
        campuses: uni.campuses
      }))
    });
  } catch (error) {
    logger.error('Public universities lookup error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/reference/campuses
// @desc    Public list of campuses (optionally filtered by university)
// @access  Public
router.get('/campuses', async (req, res) => {
  try {
    const { universityId } = req.query;

    const where = {};
    if (universityId) where.universityId = universityId;

    const campuses = await prisma.campus.findMany({
      where,
      include: {
        university: {
          select: { id: true, name: true }
        }
      },
      orderBy: { name: 'asc' }
    });

    res.status(200).json({
      success: true,
      data: campuses.map((campus) => ({
        id: campus.id,
        name: campus.name,
        universityId: campus.universityId,
        universityName: campus.university?.name || null,
        address: campus.address,
        latitude: campus.latitude,
        longitude: campus.longitude
      }))
    });
  } catch (error) {
    logger.error('Public campuses lookup error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
