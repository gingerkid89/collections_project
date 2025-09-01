// middleware/auth.js - JWT Authentication Middleware
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// JWT Secret from environment or default for development
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

/**
 * Generate JWT token for user
 */
const generateToken = (userId, email) => {
  return jwt.sign(
    { 
      userId, 
      email,
      iat: Math.floor(Date.now() / 1000)
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
};

/**
 * Hash password using bcrypt
 */
const hashPassword = async (password) => {
  const saltRounds = 12;
  return await bcrypt.hash(password, saltRounds);
};

/**
 * Compare password with hash
 */
const comparePassword = async (password, hash) => {
  return await bcrypt.compare(password, hash);
};

/**
 * Verify JWT token middleware
 */
const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      error: 'Access Denied',
      message: 'No token provided. Please include a valid JWT token in the Authorization header.'
    });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // Add user info to request
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Token Expired',
        message: 'Your session has expired. Please login again.'
      });
    } else if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Invalid Token',
        message: 'The provided token is invalid.'
      });
    } else {
      return res.status(401).json({
        error: 'Authentication Failed',
        message: 'Token verification failed.'
      });
    }
  }
};

/**
 * Optional authentication middleware - doesn't fail if no token
 */
const optionalAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (token) {
    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      req.user = decoded;
    } catch (error) {
      // Token invalid but we continue without user info
      req.user = null;
    }
  }
  
  next();
};

/**
 * Admin role check middleware (requires verifyToken first)
 */
const requireAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      error: 'Authentication Required',
      message: 'Please authenticate to access this resource.'
    });
  }

  // For now, check if user email is admin
  // In production, you'd have a roles field in the database
  const adminEmails = ['admin@collections.com', 'user@web.com']; // Include test user as admin
  
  if (!adminEmails.includes(req.user.email)) {
    return res.status(403).json({
      error: 'Forbidden',
      message: 'Administrator privileges required.'
    });
  }

  next();
};

/**
 * Check if user owns resource or is admin
 */
const requireOwnershipOrAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      error: 'Authentication Required',
      message: 'Please authenticate to access this resource.'
    });
  }

  const resourceUserId = req.params.userId || req.body.userId;
  const adminEmails = ['admin@collections.com', 'user@web.com'];
  
  if (req.user.userId !== resourceUserId && !adminEmails.includes(req.user.email)) {
    return res.status(403).json({
      error: 'Forbidden',
      message: 'You can only access your own resources.'
    });
  }

  next();
};

module.exports = {
  generateToken,
  hashPassword,
  comparePassword,
  verifyToken,
  optionalAuth,
  requireAdmin,
  requireOwnershipOrAdmin,
  JWT_SECRET
};