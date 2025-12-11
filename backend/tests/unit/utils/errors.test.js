const {
  AppError,
  ValidationError,
  AuthenticationError,
  AuthorizationError,
  NotFoundError,
  ConflictError,
  InternalServerError,
} = require('../../../src/utils/errors');

describe('Custom Error Classes', () => {
  describe('AppError', () => {
    it('should create an error with message and status code', () => {
      const error = new AppError('Test error', 400);
      expect(error.message).toBe('Test error');
      expect(error.statusCode).toBe(400);
      expect(error.isOperational).toBe(true);
    });
  });

  describe('ValidationError', () => {
    it('should create a validation error with 400 status', () => {
      const error = new ValidationError('Invalid input');
      expect(error.message).toBe('Invalid input');
      expect(error.statusCode).toBe(400);
      expect(error.name).toBe('ValidationError');
    });

    it('should have default message', () => {
      const error = new ValidationError();
      expect(error.message).toBe('Validation failed');
    });
  });

  describe('AuthenticationError', () => {
    it('should create an authentication error with 401 status', () => {
      const error = new AuthenticationError('Invalid token');
      expect(error.message).toBe('Invalid token');
      expect(error.statusCode).toBe(401);
      expect(error.name).toBe('AuthenticationError');
    });
  });

  describe('AuthorizationError', () => {
    it('should create an authorization error with 403 status', () => {
      const error = new AuthorizationError('Access denied');
      expect(error.message).toBe('Access denied');
      expect(error.statusCode).toBe(403);
      expect(error.name).toBe('AuthorizationError');
    });
  });

  describe('NotFoundError', () => {
    it('should create a not found error with 404 status', () => {
      const error = new NotFoundError('User');
      expect(error.message).toBe('User not found');
      expect(error.statusCode).toBe(404);
      expect(error.name).toBe('NotFoundError');
    });
  });

  describe('ConflictError', () => {
    it('should create a conflict error with 409 status', () => {
      const error = new ConflictError('User already exists');
      expect(error.message).toBe('User already exists');
      expect(error.statusCode).toBe(409);
      expect(error.name).toBe('ConflictError');
    });
  });

  describe('InternalServerError', () => {
    it('should create an internal server error with 500 status', () => {
      const error = new InternalServerError('Server error');
      expect(error.message).toBe('Server error');
      expect(error.statusCode).toBe(500);
      expect(error.name).toBe('InternalServerError');
    });
  });
});
