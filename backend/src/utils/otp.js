const generateOTP = () => {
  const length = parseInt(process.env.OTP_LENGTH) || 6;
  const digits = '0123456789';
  let otp = '';
  
  for (let i = 0; i < length; i++) {
    otp += digits[Math.floor(Math.random() * digits.length)];
  }
  
  return otp;
};

const getOTPExpiry = () => {
  const expiryMinutes = parseInt(process.env.OTP_EXPIRY_MINUTES) || 10;
  return new Date(Date.now() + expiryMinutes * 60000);
};

const verifyOTP = (storedOTP, providedOTP, expiryDate) => {
  if (!storedOTP || !providedOTP) {
    return { valid: false, message: 'OTP is required' };
  }

  if (new Date() > expiryDate) {
    return { valid: false, message: 'OTP has expired' };
  }

  if (storedOTP !== providedOTP) {
    return { valid: false, message: 'Invalid OTP' };
  }

  return { valid: true, message: 'OTP verified successfully' };
};

module.exports = {
  generateOTP,
  getOTPExpiry,
  verifyOTP
};
