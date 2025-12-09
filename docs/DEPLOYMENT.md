# Deployment Guide

## Quick Start with Docker Compose

### Prerequisites
- Docker and Docker Compose installed
- Domain name (optional for production)
- SSL certificate (for HTTPS)

### Step 1: Clone Repository
```bash
git clone https://github.com/petmsyh/campus_eats.git
cd campus_eats
```

### Step 2: Configure Environment
```bash
# Create .env file in root directory
cat > .env << EOF
JWT_SECRET=your-super-secret-jwt-key-change-this
CHAPA_SECRET_KEY=your-chapa-secret-key
CHAPA_PUBLIC_KEY=your-chapa-public-key
FCM_SERVER_KEY=your-fcm-server-key
FCM_PROJECT_ID=your-firebase-project-id
EOF
```

### Step 3: Start Services
```bash
# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f backend

# Check status
docker-compose ps
```

### Step 4: Verify Installation
```bash
# Health check
curl http://localhost:3000/health

# Should return: {"status":"OK","message":"Campus Eats API is running"}
```

## Production Deployment

### Option 1: Deploy to Heroku

```bash
# Install Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# Login
heroku login

# Create app
heroku create campus-eats-api

# Add MongoDB
heroku addons:create mongolab:sandbox

# Set environment variables
heroku config:set JWT_SECRET="your-secret"
heroku config:set CHAPA_SECRET_KEY="your-chapa-key"
heroku config:set CHAPA_PUBLIC_KEY="your-public-key"
heroku config:set FCM_SERVER_KEY="your-fcm-key"
heroku config:set NODE_ENV="production"

# Deploy
git subtree push --prefix backend heroku main

# Or using Heroku Git
cd backend
git init
heroku git:remote -a campus-eats-api
git add .
git commit -m "Initial deploy"
git push heroku main

# Check logs
heroku logs --tail

# Open app
heroku open
```

### Option 2: Deploy to DigitalOcean

```bash
# Create Droplet (Ubuntu 22.04)
# SSH into server

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install MongoDB
# Follow: https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/

# Install PM2
sudo npm install -g pm2

# Clone repository
git clone https://github.com/petmsyh/campus_eats.git
cd campus_eats/backend

# Install dependencies
npm ci --production

# Configure environment
nano .env
# Add your configuration

# Start with PM2
pm2 start src/server.js --name campus-eats-api
pm2 save
pm2 startup

# Setup Nginx reverse proxy
sudo apt install nginx

# Create Nginx config
sudo nano /etc/nginx/sites-available/campus-eats

# Add:
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/campus-eats /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Setup SSL with Certbot
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Option 3: Deploy to AWS EC2

Similar to DigitalOcean, but:
1. Create EC2 instance (t2.micro for testing)
2. Configure security groups (ports 22, 80, 443, 3000)
3. Follow DigitalOcean steps above

### Option 4: Deploy with Docker

```bash
# Build image
docker build -t campus-eats-backend ./backend

# Run container
docker run -d \
  --name campus-eats-api \
  -p 3000:3000 \
  -e MONGODB_URI="your-mongodb-uri" \
  -e JWT_SECRET="your-secret" \
  campus-eats-backend

# Or use docker-compose (recommended)
docker-compose up -d
```

## MongoDB Setup

### Option 1: MongoDB Atlas (Recommended for production)

1. Create account at https://www.mongodb.com/cloud/atlas
2. Create a cluster (Free tier available)
3. Create database user
4. Whitelist IP addresses (0.0.0.0/0 for all, or specific IPs)
5. Get connection string
6. Update `MONGODB_URI` in .env

Connection string format:
```
mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/campus_eats?retryWrites=true&w=majority
```

### Option 2: Self-hosted MongoDB

```bash
# Install MongoDB
# Ubuntu
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Secure MongoDB
mongo
use admin
db.createUser({
  user: "admin",
  pwd: "your-password",
  roles: ["root"]
})
exit

# Enable authentication
sudo nano /etc/mongod.conf
# Add:
security:
  authorization: enabled

sudo systemctl restart mongod
```

## Mobile App Deployment

### Android

```bash
cd frontend

# Update version in pubspec.yaml
version: 2.0.0+1

# Build release APK
flutter build apk --release --no-tree-shake-icons

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

**Upload to Google Play Console:**
1. Create developer account ($25 one-time fee)
2. Create app in console
3. Upload AAB file
4. Fill app details, screenshots
5. Submit for review

### iOS

```bash
cd frontend

# Update version
# ios/Runner/Info.plist

# Build
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Any iOS Device" as target
# 2. Product > Archive
# 3. Distribute App
# 4. Upload to App Store Connect
```

**Upload to App Store:**
1. Create developer account ($99/year)
2. Create app in App Store Connect
3. Archive and upload via Xcode
4. Fill app details, screenshots
5. Submit for review

## Environment Variables Reference

### Backend Required Variables

```env
# Core
NODE_ENV=production
PORT=3000

# Database
MONGODB_URI=mongodb://...

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# Chapa Payment
CHAPA_SECRET_KEY=your-chapa-secret
CHAPA_PUBLIC_KEY=your-chapa-public-key
CHAPA_WEBHOOK_URL=https://your-api.com/api/v1/payments/webhook

# Firebase
FCM_SERVER_KEY=your-fcm-key
FCM_PROJECT_ID=your-project-id

# Commission
SYSTEM_COMMISSION_RATE=0.05
```

### Mobile App Configuration

Update `lib/config/env.dart`:
```dart
class Environment {
  static const String apiBaseUrl = 'https://api.campuseats.et/api/v1';
  static const String chapaPublicKey = 'CHHAPI_PUBLIC_KEY';
}
```

## Monitoring & Maintenance

### Setup Monitoring

```bash
# Install monitoring tools
npm install -g pm2

# Start with PM2
pm2 start src/server.js --name campus-eats-api

# Monitor
pm2 monit

# View logs
pm2 logs campus-eats-api

# Setup log rotation
pm2 install pm2-logrotate
```

### Database Backups

```bash
# MongoDB backup
mongodump --uri="mongodb://..." --out=/backup/$(date +%Y%m%d)

# Restore
mongorestore --uri="mongodb://..." /backup/20231201

# Automated backups (cron)
crontab -e
# Add: 0 2 * * * /usr/bin/mongodump --uri="..." --out=/backup/$(date +\%Y\%m\%d)
```

### Update Application

```bash
# Pull latest code
git pull origin main

# Backend update
cd backend
npm install
pm2 restart campus-eats-api

# Mobile app update
# Build new version and upload to stores
```

## Troubleshooting

### Backend not starting
```bash
# Check logs
pm2 logs campus-eats-api
# or
docker-compose logs backend

# Common issues:
# - MongoDB not accessible
# - Environment variables not set
# - Port already in use
```

### Database connection failed
```bash
# Test MongoDB connection
mongo "mongodb://..."

# Check firewall
sudo ufw status
sudo ufw allow 27017
```

### Mobile app can't connect to API
```bash
# Check API URL in app config
# Verify API is accessible
curl https://your-api.com/health

# Check CORS settings in backend
```

## Security Checklist

- [ ] Change default passwords
- [ ] Use strong JWT secret
- [ ] Enable HTTPS/SSL
- [ ] Configure firewall
- [ ] Set up rate limiting
- [ ] Regular security updates
- [ ] Backup database regularly
- [ ] Monitor logs for suspicious activity
- [ ] Use environment variables for secrets
- [ ] Implement API authentication

## Performance Optimization

1. **Database Indexing**
   - Add indexes on frequently queried fields
   - Use compound indexes where appropriate

2. **Caching**
   - Implement Redis for session storage
   - Cache frequently accessed data

3. **CDN**
   - Use CDN for static assets
   - Optimize images

4. **Load Balancing**
   - Use Nginx or AWS ELB
   - Horizontal scaling

## Support

For deployment issues:
- Email: support@campuseats.et
- GitHub Issues: https://github.com/petmsyh/campus_eats/issues
- Documentation: https://docs.campuseats.et

---

**Last Updated**: December 2024
