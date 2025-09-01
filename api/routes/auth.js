// routes/auth.js - Authentication Routes
const express = require('express');
const { Pool } = require('pg');
const { generateToken, hashPassword, comparePassword } = require('../middleware/auth');
const { validationRules } = require('../middleware/validation');
const router = express.Router();

// Database connection
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5433,
  database: process.env.DB_NAME || 'collections_app',
  user: process.env.DB_USER || 'collections_user',
  password: process.env.DB_PASSWORD || 'password123',
});

/**
 * POST /api/v1/auth/login
 * Authenticate user and return JWT token
 */
router.post('/login', validationRules.login, async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user in database
    const userQuery = 'SELECT id, email, password_hash, display_name FROM users WHERE email = $1';
    const userResult = await pool.query(userQuery, [email]);

    if (userResult.rows.length === 0) {
      return res.status(401).json({
        error: 'Authentication Failed',
        message: 'Invalid email or password'
      });
    }

    const user = userResult.rows[0];

    // Verify password
    const isValidPassword = await comparePassword(password, user.password_hash);
    
    if (!isValidPassword) {
      return res.status(401).json({
        error: 'Authentication Failed',
        message: 'Invalid email or password'
      });
    }

    // Generate JWT token
    const token = generateToken(user.id, user.email);

    // Update last login (optional)
    await pool.query(
      'UPDATE users SET updated_at = NOW() WHERE id = $1',
      [user.id]
    );

    res.json({
      message: 'Login successful',
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          displayName: user.display_name
        }
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Login failed'
    });
  }
});

/**
 * POST /api/v1/auth/register
 * Register new user account
 */
router.post('/register', validationRules.register, async (req, res) => {
  try {
    const { email, password, displayName } = req.body;

    // Check if user already exists
    const existingUserQuery = 'SELECT id FROM users WHERE email = $1';
    const existingUser = await pool.query(existingUserQuery, [email]);

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        error: 'User Already Exists',
        message: 'An account with this email already exists'
      });
    }

    // Hash password
    const passwordHash = await hashPassword(password);

    // Create new user
    const insertUserQuery = `
      INSERT INTO users (email, password_hash, display_name, created_at, updated_at)
      VALUES ($1, $2, $3, NOW(), NOW())
      RETURNING id, email, display_name, created_at
    `;

    const newUser = await pool.query(insertUserQuery, [
      email,
      passwordHash,
      displayName || email.split('@')[0] // Use email prefix as default display name
    ]);

    const user = newUser.rows[0];

    // Generate JWT token
    const token = generateToken(user.id, user.email);

    res.status(201).json({
      message: 'Registration successful',
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          displayName: user.display_name,
          createdAt: user.created_at
        }
      }
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Registration failed'
    });
  }
});

/**
 * POST /api/v1/auth/verify
 * Verify JWT token and return user info
 */
router.post('/verify', async (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      error: 'No Token',
      message: 'No token provided'
    });
  }

  try {
    const jwt = require('jsonwebtoken');
    const { JWT_SECRET } = require('../middleware/auth');
    
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // Fetch fresh user data
    const userQuery = 'SELECT id, email, display_name FROM users WHERE id = $1';
    const userResult = await pool.query(userQuery, [decoded.userId]);

    if (userResult.rows.length === 0) {
      return res.status(401).json({
        error: 'User Not Found',
        message: 'User associated with token no longer exists'
      });
    }

    const user = userResult.rows[0];

    res.json({
      message: 'Token valid',
      data: {
        user: {
          id: user.id,
          email: user.email,
          displayName: user.display_name
        },
        tokenExpiry: decoded.exp
      }
    });

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
    }

    console.error('Token verification error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Token verification failed'
    });
  }
});

/**
 * POST /api/v1/auth/logout
 * Logout user (client should remove token)
 */
router.post('/logout', (req, res) => {
  // With JWT, logout is mainly handled client-side by removing the token
  // Here we just send a success response
  res.json({
    message: 'Logout successful',
    note: 'Please remove the JWT token from your client storage'
  });
});

module.exports = router;