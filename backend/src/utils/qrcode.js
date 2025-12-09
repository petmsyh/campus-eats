const QRCode = require('qrcode');
const crypto = require('crypto');

const generateQRData = (orderId) => {
  const timestamp = Date.now();
  const random = crypto.randomBytes(8).toString('hex');
  return `CE-${orderId}-${timestamp}-${random}`;
};

const generateQRCode = async (data) => {
  try {
    const qrCodeImage = await QRCode.toDataURL(data, {
      errorCorrectionLevel: 'H',
      type: 'image/png',
      quality: 0.95,
      margin: 1,
      width: 300
    });
    return qrCodeImage;
  } catch (error) {
    throw new Error('Failed to generate QR code');
  }
};

const verifyQRCode = (qrData) => {
  try {
    // QR format: CE-{orderId}-{timestamp}-{random}
    const parts = qrData.split('-');
    if (parts.length !== 4 || parts[0] !== 'CE') {
      return { valid: false, orderId: null };
    }

    const orderId = parts[1];
    return { valid: true, orderId };
  } catch (error) {
    return { valid: false, orderId: null };
  }
};

module.exports = {
  generateQRData,
  generateQRCode,
  verifyQRCode
};
