// server.js - Main Express server
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import route modules
const authRoutes = require('./routes/auth');
const placesRoutes = require('./routes/places');
const visitsRoutes = require('./routes/visits');
const userRoutes = require('./routes/user');
const exhibitionsRoutes = require('./routes/exhibitions');
const collectionsRoutes = require('./routes/collections');

const app = express();
const PORT = process.env.PORT || 8080;

// Security middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// CORS configuration for Flutter app
const allowedOrigins = process.env.NODE_ENV === 'production' 
  ? [process.env.CORS_ORIGIN, 'https://localhost:3000'].filter(Boolean)
  : true; // Allow all origins in development

app.use(cors({
  origin: allowedOrigins,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: false
}));

// Enhanced rate limiting with different limits for different endpoints
const createLimiter = (windowMs, max, message) => rateLimit({
  windowMs,
  max,
  message: { error: 'Rate Limit Exceeded', message },
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict rate limiting for auth endpoints
const authLimiter = createLimiter(
  15 * 60 * 1000, // 15 minutes
  5, // 5 attempts per window
  'Too many authentication attempts. Please try again in 15 minutes.'
);

// Moderate rate limiting for write operations
const writeLimiter = createLimiter(
  60 * 1000, // 1 minute
  30, // 30 requests per minute
  'Too many write requests. Please slow down.'
);

// General rate limiting for all API endpoints
const generalLimiter = createLimiter(
  15 * 60 * 1000, // 15 minutes
  1000, // 1000 requests per window
  'Too many requests from this IP, please try again later.'
);

// Apply rate limiters
app.use('/api/v1/auth', authLimiter);
app.use('/api/v1/places', (req, res, next) => {
  if (req.method === 'POST') {
    writeLimiter(req, res, next);
  } else {
    next();
  }
});
app.use('/api/v1/visits', (req, res, next) => {
  if (req.method === 'POST') {
    writeLimiter(req, res, next);
  } else {
    next();
  }
});
app.use('/api/', generalLimiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// API routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/places', placesRoutes);
app.use('/api/v1/visits', visitsRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/exhibitions', exhibitionsRoutes);
app.use('/api/v1/collections', collectionsRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV
  });
});

// API documentation endpoint
app.get('/api', (req, res) => {
  res.json({
    name: 'Collections API',
    version: '1.0.0',
    description: 'REST API for Collections App - Places, Restaurants, Museums, and Visits',
    endpoints: {
      health: 'GET /api/health',
      auth: {
        'Login': 'POST /api/v1/auth/login',
        'Register': 'POST /api/v1/auth/register',
        'Verify token': 'POST /api/v1/auth/verify',
        'Logout': 'POST /api/v1/auth/logout'
      },
      places: {
        'All places (public)': 'GET /api/v1/places',
        'Single place (public)': 'GET /api/v1/places/:id',
        'Place menu (public)': 'GET /api/v1/places/:id/menu',
        'Create place': 'POST /api/v1/places [Auth Required]'
      },
      visits: {
        'Public visits': 'GET /api/v1/visits',
        'Create visit': 'POST /api/v1/visits [Auth Required]'
      },
      user: {
        'User places': 'GET /api/v1/user/:userId/places [Auth Required]',
        'User favorites': 'GET /api/v1/user/:userId/favorites [Auth Required]',
        'User stats': 'GET /api/v1/user/:userId/stats [Auth Required]'
      },
      exhibitions: {
        'All exhibitions': 'GET /api/v1/exhibitions',
        'Museum exhibitions': 'GET /api/v1/exhibitions?museumId=:museumId'
      }
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`,
    availableRoutes: '/api'
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('❌ Error:', err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Collections API server running on http://localhost:${PORT}`);
  console.log(`🌐 Also accessible on local network at http://YOUR_IP:${PORT}`);
  console.log(`📚 API documentation available at http://localhost:${PORT}/api`);
  console.log(`🏥 Health check available at http://localhost:${PORT}/api/health`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV}`);
});