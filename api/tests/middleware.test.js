// tests/middleware.test.js - Middleware security tests
const request = require('supertest');
const express = require('express');
const { verifyToken, requireAdmin, requireOwnershipOrAdmin, optionalAuth } = require('../middleware/auth');
const { validationRules, sanitizeInput } = require('../middleware/validation');
const { generateToken } = require('../middleware/auth');

describe('Authentication Middleware', () => {
  let app;
  
  beforeEach(() => {
    app = express();
    app.use(express.json());
  });

  describe('verifyToken middleware', () => {
    test('should reject requests without Authorization header', async () => {
      app.get('/protected', verifyToken, (req, res) => {
        res.json({ message: 'success', user: req.user });
      });

      const response = await request(app).get('/protected');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Access Denied');
      expect(response.body.message).toContain('No token provided');
    });

    test('should reject requests with invalid token format', async () => {
      app.get('/protected', verifyToken, (req, res) => {
        res.json({ message: 'success', user: req.user });
      });

      const response = await request(app)
        .get('/protected')
        .set('Authorization', 'InvalidFormat');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Access Denied');
    });

    test('should reject requests with malformed JWT', async () => {
      app.get('/protected', verifyToken, (req, res) => {
        res.json({ message: 'success', user: req.user });
      });

      const response = await request(app)
        .get('/protected')
        .set('Authorization', 'Bearer invalid.jwt.token');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Invalid Token');
    });

    test('should accept valid JWT token', async () => {
      const token = generateToken('test-user-id', 'test@example.com');
      
      app.get('/protected', verifyToken, (req, res) => {
        res.json({ message: 'success', user: req.user });
      });

      const response = await request(app)
        .get('/protected')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('success');
      expect(response.body.user.userId).toBe('test-user-id');
      expect(response.body.user.email).toBe('test@example.com');
    });

    test('should handle expired tokens', async () => {
      const jwt = require('jsonwebtoken');
      const { JWT_SECRET } = require('../middleware/auth');
      
      const expiredToken = jwt.sign(
        { userId: 'test-id', email: 'test@example.com' },
        JWT_SECRET,
        { expiresIn: '-1s' }
      );

      app.get('/protected', verifyToken, (req, res) => {
        res.json({ message: 'success' });
      });

      const response = await request(app)
        .get('/protected')
        .set('Authorization', `Bearer ${expiredToken}`);

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Token Expired');
    });
  });

  describe('optionalAuth middleware', () => {
    test('should continue without error when no token provided', async () => {
      app.get('/optional', optionalAuth, (req, res) => {
        res.json({ user: req.user });
      });

      const response = await request(app).get('/optional');

      expect(response.status).toBe(200);
      expect(response.body.user).toBeUndefined();
    });

    test('should set user when valid token provided', async () => {
      const token = generateToken('test-user-id', 'test@example.com');
      
      app.get('/optional', optionalAuth, (req, res) => {
        res.json({ user: req.user });
      });

      const response = await request(app)
        .get('/optional')
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body.user.userId).toBe('test-user-id');
    });

    test('should continue with null user when invalid token provided', async () => {
      app.get('/optional', optionalAuth, (req, res) => {
        res.json({ user: req.user });
      });

      const response = await request(app)
        .get('/optional')
        .set('Authorization', 'Bearer invalid.token.here');

      expect(response.status).toBe(200);
      expect(response.body.user).toBeNull();
    });
  });

  describe('requireAdmin middleware', () => {
    test('should reject when no user in request', async () => {
      app.get('/admin', requireAdmin, (req, res) => {
        res.json({ message: 'admin access granted' });
      });

      const response = await request(app).get('/admin');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Authentication Required');
    });

    test('should reject non-admin user', async () => {
      app.use((req, res, next) => {
        req.user = { userId: 'test-id', email: 'regular@example.com' };
        next();
      });
      
      app.get('/admin', requireAdmin, (req, res) => {
        res.json({ message: 'admin access granted' });
      });

      const response = await request(app).get('/admin');

      expect(response.status).toBe(403);
      expect(response.body.error).toBe('Forbidden');
      expect(response.body.message).toContain('Administrator privileges required');
    });

    test('should allow admin user', async () => {
      app.use((req, res, next) => {
        req.user = { userId: 'admin-id', email: 'user@web.com' };
        next();
      });
      
      app.get('/admin', requireAdmin, (req, res) => {
        res.json({ message: 'admin access granted' });
      });

      const response = await request(app).get('/admin');

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('admin access granted');
    });
  });

  describe('requireOwnershipOrAdmin middleware', () => {
    test('should reject when no user in request', async () => {
      app.get('/user/:userId/data', requireOwnershipOrAdmin, (req, res) => {
        res.json({ message: 'access granted' });
      });

      const response = await request(app).get('/user/test-id/data');

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Authentication Required');
    });

    test('should reject when user tries to access another users data', async () => {
      app.use((req, res, next) => {
        req.user = { userId: 'user-1', email: 'user1@example.com' };
        next();
      });
      
      app.get('/user/:userId/data', requireOwnershipOrAdmin, (req, res) => {
        res.json({ message: 'access granted' });
      });

      const response = await request(app).get('/user/user-2/data');

      expect(response.status).toBe(403);
      expect(response.body.error).toBe('Forbidden');
      expect(response.body.message).toContain('You can only access your own resources');
    });

    test('should allow user to access their own data', async () => {
      app.use((req, res, next) => {
        req.user = { userId: 'user-1', email: 'user1@example.com' };
        next();
      });
      
      app.get('/user/:userId/data', requireOwnershipOrAdmin, (req, res) => {
        res.json({ message: 'access granted' });
      });

      const response = await request(app).get('/user/user-1/data');

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('access granted');
    });

    test('should allow admin to access any users data', async () => {
      app.use((req, res, next) => {
        req.user = { userId: 'admin-id', email: 'user@web.com' };
        next();
      });
      
      app.get('/user/:userId/data', requireOwnershipOrAdmin, (req, res) => {
        res.json({ message: 'access granted' });
      });

      const response = await request(app).get('/user/any-user-id/data');

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('access granted');
    });
  });
});

describe('Validation Middleware', () => {
  let app;
  
  beforeEach(() => {
    app = express();
    app.use(express.json());
  });

  describe('sanitizeInput middleware', () => {
    test('should remove script tags from input', async () => {
      app.post('/test', sanitizeInput, (req, res) => {
        res.json(req.body);
      });

      const maliciousInput = {
        name: 'Test <script>alert("xss")</script> Restaurant',
        description: 'Good food <script>malicious()</script>'
      };

      const response = await request(app)
        .post('/test')
        .send(maliciousInput);

      expect(response.status).toBe(200);
      expect(response.body.name).toBe('Test  Restaurant');
      expect(response.body.description).toBe('Good food ');
    });

    test('should preserve safe HTML and content', async () => {
      app.post('/test', sanitizeInput, (req, res) => {
        res.json(req.body);
      });

      const safeInput = {
        name: 'Test Restaurant & Café',
        description: 'Great food with <em>emphasis</em>',
        price: 25.99
      };

      const response = await request(app)
        .post('/test')
        .send(safeInput);

      expect(response.status).toBe(200);
      expect(response.body.name).toBe('Test Restaurant & Café');
      expect(response.body.description).toBe('Great food with <em>emphasis</em>');
      expect(response.body.price).toBe(25.99);
    });
  });

  describe('validation rules', () => {
    test('createPlace validation should reject invalid data', async () => {
      app.post('/places', validationRules.createPlace, (req, res) => {
        res.json({ message: 'Place created' });
      });

      const invalidPlace = {
        name: 'A', // Too short
        type: 'invalid-type', // Invalid type
        address: '123' // Too short
      };

      const response = await request(app)
        .post('/places')
        .send(invalidPlace);

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
      expect(response.body.details.length).toBeGreaterThan(0);
    });

    test('createPlace validation should accept valid data', async () => {
      app.post('/places', validationRules.createPlace, (req, res) => {
        res.json({ message: 'Place created' });
      });

      const validPlace = {
        name: 'Valid Restaurant',
        type: 'restaurant',
        address: '123 Valid Street, Valid City, 12345'
      };

      const response = await request(app)
        .post('/places')
        .send(validPlace);

      expect(response.status).toBe(200);
      expect(response.body.message).toBe('Place created');
    });

    test('login validation should reject invalid email', async () => {
      app.post('/login', validationRules.login, (req, res) => {
        res.json({ message: 'Login successful' });
      });

      const invalidLogin = {
        email: 'not-an-email',
        password: 'validpassword123'
      };

      const response = await request(app)
        .post('/login')
        .send(invalidLogin);

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });

    test('createVisit validation should validate rating range', async () => {
      app.post('/visits', validationRules.createVisit, (req, res) => {
        res.json({ message: 'Visit created' });
      });

      const invalidVisit = {
        placeId: 'not-a-uuid',
        date: 'invalid-date',
        overallRating: 6.0 // Out of range (1.0-5.0)
      };

      const response = await request(app)
        .post('/visits')
        .send(invalidVisit);

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
      expect(response.body.details.length).toBeGreaterThanOrEqual(2);
    });
  });
});