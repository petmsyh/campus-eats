const path = require('path');

require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const bcrypt = require('bcryptjs');
const { Pool } = require('pg');
const { PrismaPg } = require('@prisma/adapter-pg');
const { PrismaClient } = require('@prisma/client');

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is not defined. Please set it in your environment or .env file.');
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
});

const prisma = new PrismaClient({
  adapter: new PrismaPg(pool),
});

const PASSWORDS = {
  admin: process.env.SEED_ADMIN_PASSWORD || 'AdminPass123!',
  loungeOwner: process.env.SEED_LOUNGE_PASSWORD || 'LoungePass123!',
  user: process.env.SEED_USER_PASSWORD || 'UserPass123!'
};

async function seed() {
  try {
    const [adminHash, loungeHash, userHash] = await Promise.all([
      bcrypt.hash(PASSWORDS.admin, 10),
      bcrypt.hash(PASSWORDS.loungeOwner, 10),
      bcrypt.hash(PASSWORDS.user, 10)
    ]);

    const university = await prisma.university.upsert({
      where: { code: 'AAU' },
      update: {
        name: 'Addis Ababa University',
        city: 'Addis Ababa',
        region: 'Addis Ababa',
        country: 'Ethiopia'
      },
      create: {
        name: 'Addis Ababa University',
        code: 'AAU',
        city: 'Addis Ababa',
        region: 'Addis Ababa',
        country: 'Ethiopia'
      }
    });

    const campus = await prisma.campus.upsert({
      where: {
        name_universityId: {
          name: 'Main Campus',
          universityId: university.id
        }
      },
      update: {
        address: 'King George VI St',
        latitude: 8.9806,
        longitude: 38.7578
      },
      create: {
        name: 'Main Campus',
        universityId: university.id,
        address: 'King George VI St',
        latitude: 8.9806,
        longitude: 38.7578
      }
    });

    const adminUser = await prisma.user.upsert({
      where: { phone: '+251900000001' },
      update: {
        name: 'System Admin',
        email: 'admin@campuseats.com',
        password: adminHash,
        role: 'ADMIN',
        universityId: university.id,
        campusId: campus.id,
        isVerified: true
      },
      create: {
        name: 'System Admin',
        phone: '+251900000001',
        email: 'admin@campuseats.com',
        password: adminHash,
        role: 'ADMIN',
        universityId: university.id,
        campusId: campus.id,
        isVerified: true
      }
    });

    const loungeOwner = await prisma.user.upsert({
      where: { phone: '+251900000002' },
      update: {
        name: 'Lounge Owner',
        email: 'owner@campuseats.com',
        password: loungeHash,
        role: 'LOUNGE',
        universityId: university.id,
        campusId: campus.id,
        isVerified: true
      },
      create: {
        name: 'Lounge Owner',
        phone: '+251900000002',
        email: 'owner@campuseats.com',
        password: loungeHash,
        role: 'LOUNGE',
        universityId: university.id,
        campusId: campus.id,
        isVerified: true
      }
    });

    const customerUser = await prisma.user.upsert({
      where: { phone: '+251900000003' },
      update: {
        name: 'Demo Customer',
        email: 'customer@campuseats.com',
        password: userHash,
        role: 'USER',
        universityId: university.id,
        campusId: campus.id,
        isVerified: true
      },
      create: {
        name: 'Demo Customer',
        phone: '+251900000003',
        email: 'customer@campuseats.com',
        password: userHash,
        role: 'USER',
        universityId: university.id,
        campusId: campus.id,
        isVerified: true
      }
    });

    const loungePayload = {
      name: 'Sunrise Lounge',
      ownerId: loungeOwner.id,
      universityId: university.id,
      campusId: campus.id,
      description: 'Signature Ethiopian dishes, quick bites, and smoothies for students.',
      logo: null,
      accountNumber: '1000123456789',
      bankName: 'Commercial Bank of Ethiopia',
      accountHolderName: 'Lounge Owner',
      opening: '07:00',
      closing: '21:00',
      isApproved: true,
      isActive: true
    };

    const existingLounge = await prisma.lounge.findFirst({
      where: {
        ownerId: loungeOwner.id,
        name: loungePayload.name
      }
    });

    const lounge = existingLounge
      ? await prisma.lounge.update({ where: { id: existingLounge.id }, data: loungePayload })
      : await prisma.lounge.create({ data: loungePayload });

    console.log('✅ Database seeded with the following demo accounts:');
    console.table([
      { role: 'ADMIN', email: adminUser.email, phone: adminUser.phone, password: PASSWORDS.admin },
      { role: 'LOUNGE', email: loungeOwner.email, phone: loungeOwner.phone, password: PASSWORDS.loungeOwner },
      { role: 'USER', email: customerUser.email, phone: customerUser.phone, password: PASSWORDS.user }
    ]);

    console.log('🏠 Lounge ready:', lounge.name);
  } finally {
    await prisma.$disconnect();
    await pool.end();
  }
}

module.exports = { seed };
module.exports.default = seed;

if (require.main === module) {
  seed().catch((error) => {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  });
}
