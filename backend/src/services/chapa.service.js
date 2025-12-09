const axios = require('axios');
const logger = require('../utils/logger');

class ChapaService {
  constructor() {
    this.baseURL = 'https://api.chapa.co/v1';
    this.secretKey = process.env.CHAPA_SECRET_KEY;
  }

  async initializePayment(data) {
    try {
      const response = await axios.post(
        `${this.baseURL}/transaction/initialize`,
        {
          amount: data.amount,
          currency: 'ETB',
          email: data.email,
          first_name: data.firstName,
          last_name: data.lastName,
          phone_number: data.phone,
          tx_ref: data.reference,
          callback_url: process.env.CHAPA_CALLBACK_URL,
          return_url: data.returnUrl,
          customization: {
            title: 'Campus Eats',
            description: data.description || 'Food Order Payment'
          }
        },
        {
          headers: {
            'Authorization': `Bearer ${this.secretKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      logger.error('Chapa initialization error:', error.response?.data || error.message);
      return {
        success: false,
        message: error.response?.data?.message || 'Payment initialization failed'
      };
    }
  }

  async verifyPayment(reference) {
    try {
      const response = await axios.get(
        `${this.baseURL}/transaction/verify/${reference}`,
        {
          headers: {
            'Authorization': `Bearer ${this.secretKey}`
          }
        }
      );

      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      logger.error('Chapa verification error:', error.response?.data || error.message);
      return {
        success: false,
        message: error.response?.data?.message || 'Payment verification failed'
      };
    }
  }

  async getPaymentDetails(transactionId) {
    try {
      const response = await axios.get(
        `${this.baseURL}/transaction/${transactionId}`,
        {
          headers: {
            'Authorization': `Bearer ${this.secretKey}`
          }
        }
      );

      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      logger.error('Chapa get payment error:', error.response?.data || error.message);
      return {
        success: false,
        message: error.response?.data?.message || 'Failed to get payment details'
      };
    }
  }
}

module.exports = new ChapaService();
