#!/usr/bin/env node
const path = require('path');
const dotenvPath = path.resolve(__dirname, '..', '.env');
require('dotenv').config({ path: dotenvPath });
const { prisma } = require('../src/config/prisma');
const logger = require('../src/utils/logger');

async function main() {
  const loungeUsers = await prisma.user.findMany({
    where: { role: 'LOUNGE' },
    select: {
      id: true,
      name: true,
      universityId: true,
      campusId: true,
      isActive: true,
    }
  });

  const existingLounges = await prisma.lounge.findMany({
    select: { ownerId: true }
  });

  const existingOwnerIds = new Set(existingLounges.map((l) => l.ownerId));

  const missingOwners = loungeUsers.filter((user) => !existingOwnerIds.has(user.id));

  if (!missingOwners.length) {
    console.log('No missing lounges found.');
    return;
  }

  console.log(`Found ${missingOwners.length} lounge owner(s) without lounge records. Creating pending lounges...`);

  for (const owner of missingOwners) {
    await prisma.lounge.create({
      data: {
        name: `${owner.name}'s Lounge`,
        ownerId: owner.id,
        universityId: owner.universityId,
        campusId: owner.campusId,
        description: `${owner.name}'s lounge profile auto-generated pending admin approval`,
        accountNumber: null,
        bankName: null,
        accountHolderName: null,
        opening: null,
        closing: null,
        isApproved: false,
        isActive: owner.isActive,
      }
    });

    console.log(`✓ Created lounge for owner ${owner.name} (${owner.id})`);
  }

  console.log('Backfill complete.');
}

main()
  .catch((error) => {
    logger.error('Backfill lounges script error:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
