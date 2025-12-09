const express = require('express');
const router = express.Router();
const { auth, authorize } = require('../middleware/auth');
const { prisma } = require('../config/prisma');
const logger = require('../utils/logger');

const trimString = (value) => (typeof value === 'string' ? value.trim() : undefined);

const normalizeBankAccounts = (accounts) => {
  if (!Array.isArray(accounts)) return [];
  return accounts
    .map((entry) => {
      if (!entry || typeof entry !== 'object') return null;
      const accountHolderName = trimString(entry.accountHolderName);
      const bankName = trimString(entry.bankName);
      const accountNumber = trimString(entry.accountNumber);
      if (!accountHolderName && !bankName && !accountNumber) return null;
      return { accountHolderName, bankName, accountNumber };
    })
    .filter(Boolean);
};

const normalizeWallets = (wallets) => {
  if (!Array.isArray(wallets)) return [];
  return wallets
    .map((entry) => {
      if (!entry || typeof entry !== 'object') return null;
      const provider = trimString(entry.provider) ?? trimString(entry.name);
      const phoneNumber = trimString(entry.phoneNumber);
      const accountNumber = trimString(entry.accountNumber);
      const accountHolderName = trimString(entry.accountHolderName);
      const label = trimString(entry.label);
      const instructions = trimString(entry.instructions);
      const type = trimString(entry.type) ?? 'MOBILE_WALLET';
      if (!provider && !phoneNumber && !accountNumber) return null;
      return { provider, phoneNumber, accountNumber, accountHolderName, label, instructions, type };
    })
    .filter(Boolean);
};

// @route   GET /api/v1/lounges
// @desc    Get all lounges (filtered by campus if user is logged in)
// @access  Public/Private
router.get('/', async (req, res) => {
  try {
    const { universityId, campusId, search, ownerId } = req.query;

    const where = { isActive: true, isApproved: true };

    if (universityId) where.universityId = universityId;
    if (campusId) where.campusId = campusId;
    if (ownerId) where.ownerId = ownerId;
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } }
      ];
    }

    const lounges = await prisma.lounge.findMany({
      where,
      include: {
        university: { select: { name: true } },
        campus: { select: { name: true } }
      },
      orderBy: { ratingAverage: 'desc' }
    });

    // Remove bank account details
    const sanitizedLounges = lounges.map(({
      accountNumber,
      bankName,
      accountHolderName,
      bankAccounts,
      wallets,
      ...lounge
    }) => lounge);

    res.status(200).json({
      success: true,
      data: sanitizedLounges
    });
  } catch (error) {
    logger.error('Get lounges error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/lounges/my
// @desc    Get lounges owned by current user
// @access  Private (Lounge/Admin)
router.get('/my', auth, async (req, res) => {
  try {
    if (req.user.role !== 'LOUNGE' && req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Only lounge owners can access their lounges'
      });
    }

    const lounges = await prisma.lounge.findMany({
      where: req.user.role === 'ADMIN' ? {} : { ownerId: req.user.id },
      include: {
        university: { select: { id: true, name: true } },
        campus: { select: { id: true, name: true } }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.status(200).json({
      success: true,
      data: lounges
    });
  } catch (error) {
    logger.error('Get my lounges error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/lounges/:id
// @desc    Get lounge by ID (sanitized)
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const lounge = await prisma.lounge.findUnique({
      where: { id: req.params.id },
      include: {
        university: { select: { name: true } },
        campus: { select: { name: true } }
      }
    });

    if (!lounge) {
      return res.status(404).json({
        success: false,
        message: 'Lounge not found'
      });
    }

    // Remove bank account details
    const {
      accountNumber,
      bankName,
      accountHolderName,
      bankAccounts,
      wallets,
      ...sanitizedLounge
    } = lounge;

    res.status(200).json({
      success: true,
      data: sanitizedLounge
    });
  } catch (error) {
    logger.error('Get lounge error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/lounges/:id/profile
// @desc    Get detailed lounge profile (owner/admin only)
// @access  Private
router.get('/:id/profile', auth, async (req, res) => {
  try {
    const lounge = await prisma.lounge.findUnique({
      where: { id: req.params.id },
      include: {
        university: { select: { id: true, name: true } },
        campus: { select: { id: true, name: true } }
      }
    });

    if (!lounge) {
      return res.status(404).json({
        success: false,
        message: 'Lounge not found'
      });
    }

    if (req.user.role !== 'ADMIN' && lounge.ownerId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this lounge profile'
      });
    }

    const storedBankAccounts = Array.isArray(lounge.bankAccounts) ? lounge.bankAccounts : [];
    const legacyBankAccount = lounge.accountNumber || lounge.bankName || lounge.accountHolderName
      ? {
          accountHolderName: lounge.accountHolderName,
          bankName: lounge.bankName,
          accountNumber: lounge.accountNumber
        }
      : null;
    const bankAccounts = storedBankAccounts.length
      ? storedBankAccounts
      : legacyBankAccount
          ? [legacyBankAccount]
          : [];
    const wallets = Array.isArray(lounge.wallets) ? lounge.wallets : [];

    res.status(200).json({
      success: true,
      data: {
        id: lounge.id,
        name: lounge.name,
        description: lounge.description,
        logo: lounge.logo,
        university: lounge.university
          ? { id: lounge.universityId, name: lounge.university.name }
          : null,
        campus: lounge.campus
          ? { id: lounge.campusId, name: lounge.campus.name }
          : null,
        operatingHours: {
          opening: lounge.opening,
          closing: lounge.closing
        },
        bankAccount: legacyBankAccount,
        bankAccounts,
        wallets,
        isApproved: lounge.isApproved,
        isActive: lounge.isActive,
        createdAt: lounge.createdAt,
        updatedAt: lounge.updatedAt
      }
    });
  } catch (error) {
    logger.error('Get lounge profile error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   POST /api/v1/lounges
// @desc    Create a lounge
// @access  Private (User/Admin)
router.post('/', auth, async (req, res) => {
  try {
    const {
      name,
      universityId,
      campusId,
      description,
      logo,
      bankAccount,
      bankAccounts,
      wallets,
      operatingHours
    } = req.body;

    const normalizedBankAccounts = normalizeBankAccounts(bankAccounts);
    if (!normalizedBankAccounts.length && bankAccount) {
      const legacyAccounts = normalizeBankAccounts([bankAccount]);
      normalizedBankAccounts.push(...legacyAccounts);
    }
    const normalizedWallets = normalizeWallets(wallets);
    const primaryBank = normalizedBankAccounts[0];

    const lounge = await prisma.lounge.create({
      data: {
        name,
        ownerId: req.user.id,
        universityId,
        campusId,
        description,
        logo,
        accountNumber: primaryBank?.accountNumber ?? trimString(bankAccount?.accountNumber),
        bankName: primaryBank?.bankName ?? trimString(bankAccount?.bankName),
        accountHolderName: primaryBank?.accountHolderName ?? trimString(bankAccount?.accountHolderName),
        bankAccounts: normalizedBankAccounts.length ? normalizedBankAccounts : undefined,
        wallets: normalizedWallets.length ? normalizedWallets : undefined,
        opening: operatingHours?.opening,
        closing: operatingHours?.closing
      }
    });

    res.status(201).json({
      success: true,
      message: 'Lounge created successfully. Awaiting approval.',
      data: lounge
    });
  } catch (error) {
    logger.error('Create lounge error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   PUT /api/v1/lounges/:id
// @desc    Update lounge
// @access  Private (Lounge owner)
router.put('/:id', auth, async (req, res) => {
  try {
    const lounge = await prisma.lounge.findUnique({
      where: { id: req.params.id }
    });

    if (!lounge) {
      return res.status(404).json({
        success: false,
        message: 'Lounge not found'
      });
    }

    // Check ownership
    if (lounge.ownerId !== req.user.id && req.user.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this lounge'
      });
    }

    const {
      name,
      description,
      logo,
      bankAccount,
      bankAccounts,
      wallets,
      operatingHours
    } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (description) updateData.description = description;
    if (logo) updateData.logo = logo;
    if (Array.isArray(bankAccounts)) {
      const normalizedAccounts = normalizeBankAccounts(bankAccounts);
      const primaryBank = normalizedAccounts[0] ?? null;
      updateData.bankAccounts = normalizedAccounts;
      updateData.accountNumber = primaryBank?.accountNumber ?? null;
      updateData.bankName = primaryBank?.bankName ?? null;
      updateData.accountHolderName = primaryBank?.accountHolderName ?? null;
    } else if (bankAccount) {
      const [normalizedBankAccount] = normalizeBankAccounts([bankAccount]);
      if (normalizedBankAccount) {
        updateData.bankAccounts = [normalizedBankAccount];
        updateData.accountNumber = normalizedBankAccount.accountNumber ?? null;
        updateData.bankName = normalizedBankAccount.bankName ?? null;
        updateData.accountHolderName = normalizedBankAccount.accountHolderName ?? null;
      }
    }
    if (Array.isArray(wallets)) {
      updateData.wallets = normalizeWallets(wallets);
    }
    if (operatingHours) {
      if (operatingHours.opening) updateData.opening = operatingHours.opening;
      if (operatingHours.closing) updateData.closing = operatingHours.closing;
    }

    const updatedLounge = await prisma.lounge.update({
      where: { id: req.params.id },
      data: updateData
    });

    res.status(200).json({
      success: true,
      message: 'Lounge updated successfully',
      data: updatedLounge
    });
  } catch (error) {
    logger.error('Update lounge error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// @route   GET /api/v1/lounges/:id/menu
// @desc    Get lounge menu
// @access  Public
router.get('/:id/menu', async (req, res) => {
  try {
    const foods = await prisma.food.findMany({
      where: {
        loungeId: req.params.id,
        isAvailable: true
      },
      orderBy: { category: 'asc' }
    });

    res.status(200).json({
      success: true,
      data: foods
    });
  } catch (error) {
    logger.error('Get menu error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
