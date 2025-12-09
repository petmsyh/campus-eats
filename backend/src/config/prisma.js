const { PrismaClient } = require('@prisma/client');
const { Pool } = require('pg');
const { PrismaPg } = require('@prisma/adapter-pg');
const logger = require('../utils/logger');

// Create a singleton instance of PrismaClient
let prisma;
let pool;

const getPrismaClient = () => {
  if (!prisma) {
    if (!process.env.DATABASE_URL) {
      throw new Error('DATABASE_URL is not defined. Please set it in your environment or .env file.');
    }

    if (!pool) {
      pool = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
      });
    }

    const adapter = new PrismaPg(pool);

    prisma = new PrismaClient({
      adapter,
      log: process.env.NODE_ENV === 'development' 
        ? ['query', 'info', 'warn', 'error']
        : ['error'],
    });

    logger.info('✅ Prisma Client initialized');
  }
  
  return prisma;
};

// Connect to database
const connectDB = async () => {
  try {
    const client = getPrismaClient();
    await client.$connect();
    logger.info('✅ PostgreSQL Connected via Prisma');
  } catch (error) {
    logger.error('Error connecting to PostgreSQL:', error);
    process.exit(1);
  }
};

// Disconnect from database
const disconnectDB = async () => {
  try {
    if (prisma) {
      await prisma.$disconnect();
      logger.info('PostgreSQL disconnected');
      prisma = null;
    }

    if (pool) {
      await pool.end();
      pool = null;
      logger.info('PostgreSQL connection pool closed');
    }
  } catch (error) {
    logger.error('Error disconnecting from PostgreSQL:', error);
  }
};

module.exports = {
  connectDB,
  disconnectDB,
  getPrismaClient,
  get prisma() {
    return getPrismaClient();
  }
};
