const admin = require('firebase-admin');
const logger = require('../utils/logger');

class NotificationService {
  constructor() {
    // Initialize Firebase Admin only if credentials are provided
    const hasRequiredCredentials = 
      process.env.FCM_PROJECT_ID &&
      process.env.FCM_PRIVATE_KEY &&
      process.env.FCM_CLIENT_EMAIL;

    if (hasRequiredCredentials) {
      try {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: process.env.FCM_PROJECT_ID,
            privateKey: process.env.FCM_PRIVATE_KEY?.replace(/\\n/g, '\n'),
            clientEmail: process.env.FCM_CLIENT_EMAIL
          })
        });
        this.messaging = admin.messaging();
        logger.info('✅ Firebase Admin initialized');
      } catch (error) {
        logger.error('Firebase Admin initialization failed:', error.message);
        this.messaging = null;
      }
    } else {
      logger.warn('FCM credentials not provided. Required: FCM_PROJECT_ID, FCM_PRIVATE_KEY, FCM_CLIENT_EMAIL');
      this.messaging = null;
    }
  }

  async sendNotification(fcmToken, notification, data = {}) {
    if (!this.messaging) {
      logger.warn('FCM not configured, skipping notification');
      return { success: false, message: 'FCM not configured' };
    }

    try {
      const message = {
        token: fcmToken,
        notification: {
          title: notification.title,
          body: notification.body
        },
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'campus_eats_notifications'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      };

      const response = await this.messaging.send(message);
      logger.info('Notification sent successfully:', response);
      return { success: true, messageId: response };
    } catch (error) {
      logger.error('Failed to send notification:', error);
      return { success: false, message: error.message };
    }
  }

  async sendMulticast(tokens, notification, data = {}) {
    if (!this.messaging) {
      logger.warn('FCM not configured, skipping multicast notification');
      return { success: false, message: 'FCM not configured' };
    }

    try {
      const message = {
        tokens,
        notification: {
          title: notification.title,
          body: notification.body
        },
        data: {
          ...data,
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
      };

      const response = await this.messaging.sendMulticast(message);
      logger.info(`Multicast sent: ${response.successCount} success, ${response.failureCount} failed`);
      return { success: true, response };
    } catch (error) {
      logger.error('Failed to send multicast notification:', error);
      return { success: false, message: error.message };
    }
  }

  // Notification templates
  orderStatusNotification(status, orderNumber) {
    const templates = {
      preparing: {
        title: 'Order Confirmed',
        body: `Your order #${orderNumber} is being prepared.`
      },
      ready: {
        title: 'Order Ready',
        body: `Your order #${orderNumber} is ready for pickup! Show your QR code.`
      },
      delivered: {
        title: 'Order Delivered',
        body: `Your order #${orderNumber} has been delivered. Enjoy your meal!`
      },
      cancelled: {
        title: 'Order Cancelled',
        body: `Your order #${orderNumber} has been cancelled.`
      }
    };

    return templates[status] || { title: 'Order Update', body: `Your order #${orderNumber} status changed to ${status}` };
  }

  walletNotification(balance) {
    return {
      title: 'Low Wallet Balance',
      body: `Your wallet balance is low (ETB ${balance}). Please recharge your contract.`
    };
  }

  contractExpiryNotification(daysLeft) {
    return {
      title: 'Contract Expiring Soon',
      body: `Your contract will expire in ${daysLeft} days. Renew now to continue ordering.`
    };
  }
}

module.exports = new NotificationService();
