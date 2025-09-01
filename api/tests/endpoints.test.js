// tests/endpoints.test.js - API endpoint security tests
const request = require('supertest');
const express = require('express');
const cors = require('cors');
const { generateToken } = require('../middleware/auth');
const placesRoutes = require('../routes/places');
const visitsRoutes = require('../routes/visits');
const userRoutes = require('../routes/user');

// Create test app with routes
const createTestApp = () => {
  const app = express();
  app.use(cors());
  app.use(express.json());
  app.use('/api/v1/places', placesRoutes);
  app.use('/api/v1/visits', visitsRoutes);
  app.use('/api/v1/user', userRoutes);
  return app;
};

const app = createTestApp();

// Test tokens
const regularUserToken = generateToken('user-123', 'user@example.com');
const adminUserToken = generateToken('admin-123', 'user@web.com'); // Admin email
const otherUserToken = generateToken('user-456', 'other@example.com');

describe('Places Endpoints Security', () => {
  describe('GET /api/v1/places', () => {
    test('should allow public access to places list', async () => {
      const response = await request(app).get('/api/v1/places');

      // Should not return 401/403 (may return 500 due to no DB)
      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });

    test('should allow authenticated users to access places list', async () => {
      const response = await request(app)
        .get('/api/v1/places')
        .set('Authorization', `Bearer ${regularUserToken}`);

      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });

    test('should handle search parameter validation', async () => {
      const response = await request(app)
        .get('/api/v1/places?search=a'); // Too short

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });

    test('should handle type parameter validation', async () => {
      const response = await request(app)
        .get('/api/v1/places?type=invalid');

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });
  });

  describe('GET /api/v1/places/:id', () => {
    test('should allow public access to single place', async () => {
      const response = await request(app)
        .get('/api/v1/places/550e8400-e29b-41d4-a716-446655440000');

      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });

    test('should validate UUID format', async () => {
      const response = await request(app).get('/api/v1/places/invalid-id');

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });
  });

  describe('POST /api/v1/places', () => {
    test('should reject unauthenticated requests', async () => {
      const placeData = {
        name: 'Test Restaurant',
        type: 'restaurant',
        address: '123 Test Street, Test City'
      };

      const response = await request(app)
        .post('/api/v1/places')
        .send(placeData);

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Access Denied');
    });

    test('should allow authenticated users to create places', async () => {
      const placeData = {
        name: 'Test Restaurant',
        type: 'restaurant',
        address: '123 Test Street, Test City'
      };

      const response = await request(app)
        .post('/api/v1/places')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .send(placeData);

      // Should pass authentication (may fail at DB level)
      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });

    test('should reject invalid place data', async () => {
      const invalidData = {
        name: 'A', // Too short
        type: 'invalid-type',
        address: '123' // Too short
      };

      const response = await request(app)
        .post('/api/v1/places')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .send(invalidData);

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });

    test('should sanitize malicious input', async () => {
      const maliciousData = {
        name: 'Test <script>alert("xss")</script> Restaurant',
        type: 'restaurant',
        address: '123 Test Street, Test City'
      };

      const response = await request(app)
        .post('/api/v1/places')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .send(maliciousData);

      // Should pass validation and sanitization (may fail at DB)
      expect(response.status).not.toBe(400);
    });
  });
});

describe('Visits Endpoints Security', () => {
  describe('GET /api/v1/visits', () => {
    test('should allow public access to visits', async () => {
      const response = await request(app).get('/api/v1/visits');

      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });

    test('should allow authenticated access', async () => {
      const response = await request(app)
        .get('/api/v1/visits')
        .set('Authorization', `Bearer ${regularUserToken}`);

      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });
  });

  describe('POST /api/v1/visits', () => {
    test('should reject unauthenticated requests', async () => {
      const visitData = {
        placeId: '550e8400-e29b-41d4-a716-446655440000',
        date: new Date().toISOString(),
        overallRating: 4.5
      };

      const response = await request(app)
        .post('/api/v1/visits')
        .send(visitData);

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Access Denied');
    });

    test('should allow authenticated users to create visits', async () => {
      const visitData = {
        placeId: '550e8400-e29b-41d4-a716-446655440000',
        date: new Date().toISOString(),
        overallRating: 4.5
      };

      const response = await request(app)
        .post('/api/v1/visits')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .send(visitData);

      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });

    test('should validate visit data', async () => {
      const invalidVisit = {
        placeId: 'not-a-uuid',
        date: 'invalid-date',
        overallRating: 6.0 // Out of range
      };

      const response = await request(app)
        .post('/api/v1/visits')
        .set('Authorization', `Bearer ${regularUserToken}`)
        .send(invalidVisit);

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });
  });
});

describe('User Endpoints Security', () => {
  const userId = 'user-123';
  const otherUserId = 'user-456';

  describe('GET /api/v1/user/:userId/places', () => {
    test('should reject unauthenticated requests', async () => {
      const response = await request(app).get(`/api/v1/user/${userId}/places`);

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('Access Denied');
    });

    test('should allow users to access their own data', async () => {
      const response = await request(app)
        .get(`/api/v1/user/${userId}/places`)
        .set('Authorization', `Bearer ${regularUserToken}`);

      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });

    test('should reject users accessing other users data', async () => {
      const response = await request(app)
        .get(`/api/v1/user/${otherUserId}/places`)
        .set('Authorization', `Bearer ${regularUserToken}`);

      expect(response.status).toBe(403);
      expect(response.body.error).toBe('Forbidden');
    });

    test('should allow admin to access any user data', async () => {
      const response = await request(app)
        .get(`/api/v1/user/${otherUserId}/places`)
        .set('Authorization', `Bearer ${adminUserToken}`);

      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);
    });

    test('should validate user ID format', async () => {
      const response = await request(app)
        .get('/api/v1/user/invalid-id/places')
        .set('Authorization', `Bearer ${regularUserToken}`);

      expect(response.status).toBe(400);
      expect(response.body.error).toBe('Validation Error');
    });
  });

  describe('GET /api/v1/user/:userId/favorites', () => {
    test('should enforce same access control as places', async () => {
      // Unauthenticated
      let response = await request(app).get(`/api/v1/user/${userId}/favorites`);
      expect(response.status).toBe(401);

      // Own data
      response = await request(app)
        .get(`/api/v1/user/${userId}/favorites`)
        .set('Authorization', `Bearer ${regularUserToken}`);
      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);

      // Other user data
      response = await request(app)
        .get(`/api/v1/user/${otherUserId}/favorites`)
        .set('Authorization', `Bearer ${regularUserToken}`);
      expect(response.status).toBe(403);

      // Admin access
      response = await request(app)
        .get(`/api/v1/user/${otherUserId}/favorites`)
        .set('Authorization', `Bearer ${adminUserToken}`);
      expect(response.status).not.toBe(403);
    });
  });

  describe('GET /api/v1/user/:userId/stats', () => {
    test('should enforce same access control pattern', async () => {
      // Unauthenticated
      let response = await request(app).get(`/api/v1/user/${userId}/stats`);
      expect(response.status).toBe(401);

      // Own data
      response = await request(app)
        .get(`/api/v1/user/${userId}/stats`)
        .set('Authorization', `Bearer ${regularUserToken}`);
      expect(response.status).not.toBe(401);
      expect(response.status).not.toBe(403);

      // Other user data
      response = await request(app)
        .get(`/api/v1/user/${otherUserId}/stats`)
        .set('Authorization', `Bearer ${regularUserToken}`);
      expect(response.status).toBe(403);
    });
  });
});

describe('Cross-cutting Security Concerns', () => {
  test('should handle malformed JSON gracefully', async () => {
    const response = await request(app)
      .post('/api/v1/places')
      .set('Authorization', `Bearer ${regularUserToken}`)
      .set('Content-Type', 'application/json')
      .send('{"invalid": json}');

    expect(response.status).toBe(400);
  });

  test('should enforce content-type validation', async () => {
    const response = await request(app)
      .post('/api/v1/places')
      .set('Authorization', `Bearer ${regularUserToken}`)
      .send('plain text data');

    // Should handle non-JSON content appropriately
    expect([400, 415]).toContain(response.status);
  });

  test('should handle very large payloads', async () => {
    const largeData = {
      name: 'A'.repeat(10000), // Very long name
      type: 'restaurant',
      address: '123 Test Street'
    };

    const response = await request(app)
      .post('/api/v1/places')
      .set('Authorization', `Bearer ${regularUserToken}`)
      .send(largeData);

    // Should either reject or handle large payloads gracefully
    expect([400, 413, 422]).toContain(response.status);
  });
});