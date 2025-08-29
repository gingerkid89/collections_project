// server.js - Main Express server
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

// Import route modules
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
app.use(cors({
  origin: true, // Allow all origins in development
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: false // Set to false for development simplicity
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // Limit each IP to 1000 requests per windowMs (generous for development)
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// API routes
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
      places: {
        'All places': 'GET /api/v1/places',
        'Single place': 'GET /api/v1/places/:id',
        'Place menu': 'GET /api/v1/places/:id/menu',
        'Restaurants only': 'GET /api/v1/places?type=restaurant',
        'Museums only': 'GET /api/v1/places?type=museum'
      },
      visits: {
        'All visits': 'GET /api/v1/visits',
        'User visits': 'GET /api/v1/visits?userId=:userId',
        'Place visits': 'GET /api/v1/visits?placeId=:placeId',
        'Create visit': 'POST /api/v1/visits'
      },
      user: {
        'User places': 'GET /api/v1/user/:userId/places',
        'User favorites': 'GET /api/v1/user/:userId/favorites'
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