// tests/setup.js - Test setup and configuration
const { Pool } = require('pg');

// Test database configuration
const testDbConfig = {
  host: process.env.TEST_DB_HOST || 'localhost',
  port: process.env.TEST_DB_PORT || 5433,
  database: process.env.TEST_DB_NAME || 'collections_app_test',
  user: process.env.TEST_DB_USER || 'collections_user',
  password: process.env.TEST_DB_PASSWORD || 'password123',
};

let testPool;

// Global test setup
beforeAll(async () => {
  // Set test environment
  process.env.NODE_ENV = 'test';
  process.env.JWT_SECRET = 'test-jwt-secret-key';
  
  // Initialize test database connection
  testPool = new Pool(testDbConfig);
  
  try {
    // Test database connection
    await testPool.query('SELECT 1');
    console.log('✅ Test database connected');
  } catch (error) {
    console.warn('⚠️ Test database not available - using mock data for tests that require DB');
    console.warn('Error:', error.message);
  }
});

// Global test cleanup
afterAll(async () => {
  if (testPool) {
    await testPool.end();
  }
});

// Test utilities
global.testUtils = {
  // Create test user data
  createTestUser: () => ({
    email: 'test@example.com',
    password: 'testpassword123',
    displayName: 'Test User'
  }),
  
  // Create test place data
  createTestPlace: () => ({
    name: 'Test Restaurant',
    type: 'restaurant',
    address: '123 Test Street, Test City',
    phone: '+1234567890',
    website: 'https://test-restaurant.com',
    email: 'contact@test-restaurant.com',
    priceRange: '€€',
    specialData: {
      cuisine: 'Italian',
      hasReservation: true,
      hasDelivery: false,
      hasTakeout: true
    }
  }),
  
  // Create test visit data
  createTestVisit: (placeId) => ({
    placeId,
    date: new Date().toISOString(),
    overallRating: 4.5,
    notes: 'Great experience!',
    durationMinutes: 120,
    totalCost: 45.50,
    isPublic: true
  }),
  
  // Database utilities (if available)
  db: testPool,
  
  // Clean database tables for tests
  cleanDatabase: async () => {
    if (!testPool) return;
    
    try {
      await testPool.query('BEGIN');
      await testPool.query('DELETE FROM visit_activities');
      await testPool.query('DELETE FROM visits');
      await testPool.query('DELETE FROM user_place_status');
      await testPool.query('DELETE FROM menu_items');
      await testPool.query('DELETE FROM exhibitions');
      await testPool.query('DELETE FROM places');
      await testPool.query('DELETE FROM users');
      await testPool.query('COMMIT');
    } catch (error) {
      await testPool.query('ROLLBACK');
      throw error;
    }
  }
};

// Increase timeout for database operations
jest.setTimeout(30000);