// tests/auth.test.js - Authentication system tests
const request = require('supertest');
const express = require('express');
const cors = require('cors');
const authRoutes = require('../routes/auth');
const { generateToken, hashPassword, comparePassword } = require('../middleware/auth');

// Create test app
const createTestApp = () => {
  const app = express();
  app.use(cors());
  app.use(express.json());
  app.use('/api/v1/auth', authRoutes);
  return app;
};

const app = createTestApp();

describe('Authentication System', () => {
  describe('Password Hashing', () => {
    test('should hash passwords correctly', async () => {
      const password = 'testpassword123';
      const hash = await hashPassword(password);
      
      expect(hash).toBeDefined();
      expect(hash).not.toBe(password);
      expect(hash.length).toBeGreaterThan(50);
    });

    test('should verify passwords correctly', async () => {
      const password = 'testpassword123';
      const hash = await hashPassword(password);
      
      const isValid = await comparePassword(password, hash);
      const isInvalid = await comparePassword('wrongpassword', hash);
      
      expect(isValid).toBe(true);
      expect(isInvalid).toBe(false);
    });
  });

  describe('JWT Token Generation', () => {
    test('should generate valid JWT tokens', () => {
      const userId = 'test-user-id';
      const email = 'test@example.com';
      
      const token = generateToken(userId, email);
      
      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.')).toHaveLength(3); // JWT has 3 parts
    });

    test('should include correct payload in JWT', () => {
      const jwt = require('jsonwebtoken');
      const { JWT_SECRET } = require('../middleware/auth');
      
      const userId = 'test-user-id';
      const email = 'test@example.com';
      const token = generateToken(userId, email);
      
      const decoded = jwt.verify(token, JWT_SECRET);
      
      expect(decoded.userId).toBe(userId);
      expect(decoded.email).toBe(email);
      expect(decoded.iat).toBeDefined();
      expect(decoded.exp).toBeDefined();
    });
  });

  describe('POST /api/v1/auth/login', () => {
    test('should reject login with missing email', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({ password: 'testpassword123' });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
      expect(response.body.details).toEqual(
        expect.arrayContaining([
          expect.objectContaining({
            field: 'email',
            message: 'Valid email is required'
          })
        ])
      );
    });

    test('should reject login with invalid email format', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({ 
          email: 'invalid-email',
          password: 'testpassword123'
        });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });

    test('should reject login with short password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({ 
          email: 'test@example.com',
          password: '123'
        });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
      expect(response.body.details).toEqual(
        expect.arrayContaining([
          expect.objectContaining({
            field: 'password',
            message: 'Password must be at least 6 characters long'
          })
        ])
      );
    });

    test('should reject login with non-existent user', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({ 
          email: 'nonexistent@example.com',
          password: 'testpassword123'
        });

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Authentication Failed');
      expect(response.body.message).toBe('Invalid email or password');
    });

    // Note: Successful login test requires database setup
    test.skip('should login successfully with valid credentials', async () => {
      // This test requires a real database connection
      // Implementation would test against actual user records
    });
  });

  describe('POST /api/v1/auth/register', () => {
    test('should reject registration with missing fields', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({});

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
      expect(response.body.details.length).toBeGreaterThanOrEqual(2);
    });

    test('should reject registration with invalid email', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({ 
          email: 'invalid-email',
          password: 'testpassword123'
        });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });

    test('should reject registration with weak password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({ 
          email: 'test@example.com',
          password: '123'
        });

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });

    test('should accept valid registration data format', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({ 
          email: 'newuser@example.com',
          password: 'validpassword123',
          displayName: 'New User'
        });

      // Without database, this will fail at DB operation
      // But validation should pass (status won't be 400)
      expect(response.status).not.toBe(400);
    });
  });

  describe('POST /api/v1/auth/verify', () => {
    test('should reject request without token', async () => {
      const response = await request(app)
        .post('/api/v1/auth/verify');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('No Token');
    });

    test('should reject request with invalid token format', async () => {
      const response = await request(app)
        .post('/api/v1/auth/verify')
        .set('Authorization', 'Bearer invalid-token-format');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Invalid Token');
    });

    test('should reject request with malformed authorization header', async () => {
      const response = await request(app)
        .post('/api/v1/auth/verify')
        .set('Authorization', 'InvalidFormat token');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Invalid Token');
    });

    test('should handle expired token', async () => {
      // Create an expired token for testing
      const jwt = require('jsonwebtoken');
      const { JWT_SECRET } = require('../middleware/auth');
      
      const expiredToken = jwt.sign(
        { userId: 'test-id', email: 'test@example.com' },
        JWT_SECRET,
        { expiresIn: '-1s' } // Already expired
      );

      const response = await request(app)
        .post('/api/v1/auth/verify')
        .set('Authorization', `Bearer ${expiredToken}`);

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Token Expired');
    });
  });

  describe('POST /api/v1/auth/logout', () => {
    test('should return success message for logout', async () => {
      const response = await request(app)
        .post('/api/v1/auth/logout');

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Logout successful');
      expect(response.body.note).toContain('remove the JWT token');
    });
  });
});