const bcrypt = require('bcryptjs');

/**
 * Hash a password using bcrypt
 * @param {string} password - Plain text password
 * @returns {Promise<string>} Hashed password
 */
async function hashPassword(password) {
  const salt = await bcrypt.genSalt(10);
  return await bcrypt.hash(password, salt);
}

/**
 * Compare a password with its hashed version
 * @param {string} candidatePassword - Plain text password to check
 * @param {string} hashedPassword - Hashed password from database
 * @returns {Promise<boolean>} True if passwords match
 */
async function comparePassword(candidatePassword, hashedPassword) {
  return await bcrypt.compare(candidatePassword, hashedPassword);
}

/**
 * Sanitize user data by removing sensitive fields
 * @param {Object} user - User object from database
 * @returns {Object} Sanitized user object
 */
function sanitizeUser(user) {
  if (!user) return null;
  
  const { password, otpCode, otpExpiresAt, ...sanitizedUser } = user;
  return sanitizedUser;
}

module.exports = {
  hashPassword,
  comparePassword,
  sanitizeUser
};
