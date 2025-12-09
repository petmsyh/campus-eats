# Quick Start Guide - PostgreSQL Migration

## Prerequisites

- Node.js >= 18.0.0
- PostgreSQL database (local or cloud)
- npm or yarn

## Setup Steps

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Create `.env` file with your PostgreSQL connection:

```env
DATABASE_URL=postgresql://username:password@localhost:5432/campus_eats?schema=public
JWT_SECRET=your-secret-key
# ... other variables from .env.example
```

### 3. Initialize Database

```bash
# Generate Prisma Client
npm run prisma:generate

# Create database tables (option 1: migrations)
npm run prisma:migrate

# OR create database tables (option 2: direct push)
npm run prisma:push
```

### 4. Seed Data (Optional)

If you need to seed initial data:

```bash
# Create a seed script (prisma/seed.js)
# Then run:
npx prisma db seed
```

### 5. Start Application

```bash
# Development mode
npm run dev

# Production mode
npm start
```

### 6. Verify Installation

Test the health endpoint:

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "OK",
  "message": "Campus Eats API is running",
  "timestamp": "2025-12-05T19:00:00.000Z"
}
```

## Common Commands

```bash
# View database in browser
npm run prisma:studio

# Create new migration
npm run prisma:migrate

# Reset database (WARNING: deletes all data)
npx prisma migrate reset

# Format schema file
npx prisma format
```

## Testing API Endpoints

### Register User
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "phone": "251912345678",
    "email": "john@example.com",
    "password": "password123",
    "universityId": "uuid-of-university",
    "campusId": "uuid-of-campus"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "251912345678",
    "password": "password123"
  }'
```

## Troubleshooting

### Issue: Prisma Client not generated
```bash
npm run prisma:generate
```

### Issue: Database connection failed
- Check DATABASE_URL in .env
- Verify PostgreSQL is running
- Test connection: `psql $DATABASE_URL`

### Issue: Migration failed
```bash
# Check migration status
npx prisma migrate status

# Resolve failed migration
npx prisma migrate resolve --rolled-back <migration-name>
```

### Issue: Enum value errors
- Ensure all enum values are UPPERCASE
- Check Prisma schema for correct enum definitions

## Migration from MongoDB

If you're migrating existing data:

1. Export data from MongoDB
2. Transform data (convert ObjectIDs to UUIDs, adjust enum values)
3. Import into PostgreSQL using Prisma

See `POSTGRESQL_MIGRATION.md` for detailed migration guide.

## Resources

- [Prisma Docs](https://www.prisma.io/docs/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- Project Documentation: `POSTGRESQL_MIGRATION.md`
