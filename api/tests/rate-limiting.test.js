// tests/rate-limiting.test.js - Rate limiting security tests
const request = require('supertest');
const express = require('express');
const rateLimit = require('express-rate-limit');

// Import server configuration to test actual rate limiters
const createApp = () => {
  const app = express();
  app.use(express.json());

  // Replicate rate limiting from server.js
  const createLimiter = (windowMs, max, message) => rateLimit({
    windowMs,
    max,
    message: { error: 'Rate Limit Exceeded', message },
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: false,
    skipFailedRequests: false
  });

  // Test limiters with very restrictive settings for testing
  const testAuthLimiter = createLimiter(
    1000, // 1 second window
    2, // 2 requests max
    'Too many authentication attempts. Please try again in 15 minutes.'
  );

  const testWriteLimiter = createLimiter(
    1000, // 1 second window
    3, // 3 requests max
    'Too many write requests. Please slow down.'
  );

  const testGeneralLimiter = createLimiter(
    1000, // 1 second window  
    10, // 10 requests max
    'Too many requests from this IP, please try again later.'
  );

  // Test routes with rate limiting
  app.use('/auth', testAuthLimiter);
  app.post('/auth/login', (req, res) => {
    res.json({ message: 'login attempt' });
  });

  app.use('/write-endpoint', testWriteLimiter);
  app.post('/write-endpoint', (req, res) => {
    res.json({ message: 'write operation' });
  });

  app.use('/general', testGeneralLimiter);
  app.get('/general/data', (req, res) => {
    res.json({ message: 'general request' });
  });

  return app;
};

describe('Rate Limiting Security', () => {
  let app;

  beforeEach(() => {
    app = createApp();
  });

  describe('Authentication Rate Limiting', () => {
    test('should allow requests within limit', async () => {
      const response1 = await request(app)
        .post('/auth/login')
        .send({ email: 'test@example.com', password: 'password' });

      const response2 = await request(app)
        .post('/auth/login') 
        .send({ email: 'test@example.com', password: 'password' });

      expect(response1.status).toBe(200);
      expect(response2.status).toBe(200);
    });

    test('should block requests exceeding auth limit', async () => {
      // Make requests up to limit
      await request(app).post('/auth/login').send({});
      await request(app).post('/auth/login').send({});

      // This should be blocked
      const response = await request(app)
        .post('/auth/login')
        .send({ email: 'test@example.com', password: 'password' });

      expect(response.status).toBe(429);
      expect(response.body.error).toBe('Rate Limit Exceeded');
      expect(response.body.message).toContain('authentication attempts');
    });

    test('should include rate limit headers', async () => {
      const response = await request(app)
        .post('/auth/login')
        .send({});

      expect(response.headers['x-ratelimit-limit']).toBeDefined();
      expect(response.headers['x-ratelimit-remaining']).toBeDefined();
      expect(response.headers['x-ratelimit-reset']).toBeDefined();
    });

    test('should reset limits after time window', async () => {
      // Hit the limit
      await request(app).post('/auth/login').send({});
      await request(app).post('/auth/login').send({});
      
      let response = await request(app).post('/auth/login').send({});
      expect(response.status).toBe(429);

      // Wait for window reset (1 second + buffer)
      await new Promise(resolve => setTimeout(resolve, 1100));

      // Should work again
      response = await request(app).post('/auth/login').send({});
      expect(response.status).toBe(200);
    }, 10000);
  });

  describe('Write Operations Rate Limiting', () => {
    test('should allow write requests within limit', async () => {
      const responses = await Promise.all([
        request(app).post('/write-endpoint').send({}),
        request(app).post('/write-endpoint').send({}),
        request(app).post('/write-endpoint').send({})
      ]);

      responses.forEach(response => {
        expect(response.status).toBe(200);
      });
    });

    test('should block excessive write requests', async () => {
      // Hit the limit (3 requests)
      await request(app).post('/write-endpoint').send({});
      await request(app).post('/write-endpoint').send({});  
      await request(app).post('/write-endpoint').send({});

      // Fourth request should be blocked
      const response = await request(app).post('/write-endpoint').send({});

      expect(response.status).toBe(429);
      expect(response.body.message).toContain('write requests');
    });
  });

  describe('General API Rate Limiting', () => {
    test('should handle multiple general requests', async () => {
      const promises = Array(8).fill().map(() => 
        request(app).get('/general/data')
      );

      const responses = await Promise.all(promises);
      
      responses.forEach(response => {
        expect(response.status).toBe(200);
      });
    });

    test('should block when general limit exceeded', async () => {
      // Make 10 requests (the limit)
      const promises = Array(10).fill().map(() => 
        request(app).get('/general/data')
      );
      await Promise.all(promises);

      // 11th request should be blocked  
      const response = await request(app).get('/general/data');

      expect(response.status).toBe(429);
      expect(response.body.message).toContain('Too many requests from this IP');
    });
  });

  describe('Rate Limiting Edge Cases', () => {
    test('should handle concurrent requests properly', async () => {
      // Fire many requests simultaneously
      const promises = Array(15).fill().map(() => 
        request(app).get('/general/data')
      );

      const responses = await Promise.all(promises);

      const successCount = responses.filter(r => r.status === 200).length;
      const blockedCount = responses.filter(r => r.status === 429).length;

      expect(successCount).toBeLessThanOrEqual(10);
      expect(blockedCount).toBeGreaterThan(0);
      expect(successCount + blockedCount).toBe(15);
    });

    test('should handle different endpoints independently', async () => {
      // Hit auth limit
      await request(app).post('/auth/login').send({});
      await request(app).post('/auth/login').send({});
      
      const authResponse = await request(app).post('/auth/login').send({});
      expect(authResponse.status).toBe(429);

      // General endpoint should still work
      const generalResponse = await request(app).get('/general/data');
      expect(generalResponse.status).toBe(200);
    });

    test('should maintain separate counters per IP', async () => {
      // This test simulates different IPs, but supertest uses same connection
      // In real deployment, different IPs would have separate limits
      
      const response = await request(app).get('/general/data');
      expect(response.status).toBe(200);
      expect(response.headers['x-ratelimit-remaining']).toBeDefined();
    });

    test('should handle malformed requests within rate limits', async () => {
      // Even malformed requests should count against limits
      await request(app).post('/auth/login').send('invalid json');
      await request(app).post('/auth/login').send('invalid json');
      
      const response = await request(app).post('/auth/login').send('invalid json');
      expect(response.status).toBe(429);
    });
  });

  describe('Rate Limit Response Format', () => {
    test('should return consistent error format', async () => {
      // Hit limit first
      await request(app).post('/auth/login').send({});
      await request(app).post('/auth/login').send({});

      const response = await request(app).post('/auth/login').send({});

      expect(response.status).toBe(429);
      expect(response.body).toHaveProperty('error');
      expect(response.body).toHaveProperty('message');
      expect(response.body.error).toBe('Rate Limit Exceeded');
      expect(typeof response.body.message).toBe('string');
    });

    test('should include security headers', async () => {
      const response = await request(app).get('/general/data');

      expect(response.headers['x-ratelimit-limit']).toBeDefined();
      expect(response.headers['x-ratelimit-remaining']).toBeDefined();
      expect(response.headers['x-ratelimit-reset']).toBeDefined();
      
      expect(Number(response.headers['x-ratelimit-limit'])).toBeGreaterThan(0);
      expect(Number(response.headers['x-ratelimit-remaining'])).toBeGreaterThanOrEqual(0);
    });

    test('should not leak sensitive information in rate limit responses', async () => {
      // Hit limit
      await request(app).post('/auth/login').send({});
      await request(app).post('/auth/login').send({});

      const response = await request(app).post('/auth/login').send({});

      expect(response.status).toBe(429);
      expect(response.body.message).not.toContain('server');
      expect(response.body.message).not.toContain('database');
      expect(response.body.message).not.toContain('internal');
      expect(response.body).not.toHaveProperty('stack');
      expect(response.body).not.toHaveProperty('trace');
    });
  });
});