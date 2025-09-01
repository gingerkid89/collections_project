// middleware/validation.js - Request Validation Middleware
const { body, param, query, validationResult } = require('express-validator');

/**
 * Handle validation errors
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation Error',
      message: 'Request validation failed',
      details: errors.array().map(error => ({
        field: error.path,
        message: error.msg,
        value: error.value
      }))
    });
  }
  
  next();
};

/**
 * Common validation rules
 */
const validationRules = {
  // User authentication
  login: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email is required'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters long'),
    handleValidationErrors
  ],

  register: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email is required'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters long'),
    body('displayName')
      .optional()
      .isLength({ min: 2, max: 50 })
      .withMessage('Display name must be 2-50 characters long'),
    handleValidationErrors
  ],

  // Place creation
  createPlace: [
    body('name')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Place name must be 2-100 characters long'),
    body('type')
      .isIn(['restaurant', 'museum'])
      .withMessage('Place type must be either "restaurant" or "museum"'),
    body('address')
      .trim()
      .isLength({ min: 5, max: 200 })
      .withMessage('Address must be 5-200 characters long'),
    body('phone')
      .optional()
      .isMobilePhone('any')
      .withMessage('Valid phone number required'),
    body('website')
      .optional()
      .isURL()
      .withMessage('Valid website URL required'),
    body('email')
      .optional()
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email required'),
    body('priceRange')
      .optional()
      .isIn(['€', '€€', '€€€', '€€€€'])
      .withMessage('Price range must be €, €€, €€€, or €€€€'),
    handleValidationErrors
  ],

  // Visit creation
  createVisit: [
    body('placeId')
      .isUUID()
      .withMessage('Valid place ID is required'),
    body('date')
      .isISO8601()
      .toDate()
      .withMessage('Valid date is required'),
    body('overallRating')
      .optional()
      .isFloat({ min: 1.0, max: 5.0 })
      .withMessage('Rating must be between 1.0 and 5.0'),
    body('durationMinutes')
      .optional()
      .isInt({ min: 1, max: 1440 })
      .withMessage('Duration must be between 1 and 1440 minutes'),
    body('totalCost')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Total cost must be a positive number'),
    body('notes')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Notes must be less than 1000 characters'),
    handleValidationErrors
  ],

  // Menu item creation
  createMenuItem: [
    body('name')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Menu item name must be 2-100 characters long'),
    body('price')
      .isFloat({ min: 0 })
      .withMessage('Price must be a positive number'),
    body('category')
      .isIn([
        'Vorspeisen', 'Hauptgerichte', 'Nachspeisen', 'Getränke', 
        'Salate', 'Suppen', 'Pizza', 'Pasta', 'Fleisch', 
        'Fisch', 'Vegetarisch', 'Vegan', 'Kinder'
      ])
      .withMessage('Invalid menu category'),
    body('description')
      .optional()
      .isLength({ max: 500 })
      .withMessage('Description must be less than 500 characters'),
    handleValidationErrors
  ],

  // Parameter validations
  validateUUID: [
    param('id').isUUID().withMessage('Invalid ID format'),
    handleValidationErrors
  ],

  validateUserId: [
    param('userId').isUUID().withMessage('Invalid user ID format'),
    handleValidationErrors
  ],

  // Query parameter validations
  validatePlaceQuery: [
    query('type')
      .optional()
      .isIn(['restaurant', 'museum'])
      .withMessage('Type must be either "restaurant" or "museum"'),
    query('search')
      .optional()
      .isLength({ min: 2, max: 50 })
      .withMessage('Search term must be 2-50 characters long'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .toInt()
      .withMessage('Limit must be between 1 and 100'),
    query('offset')
      .optional()
      .isInt({ min: 0 })
      .toInt()
      .withMessage('Offset must be a non-negative integer'),
    handleValidationErrors
  ]
};

/**
 * Sanitize request data
 */
const sanitizeInput = (req, res, next) => {
  // Remove any potentially dangerous characters
  const sanitizeString = (str) => {
    if (typeof str !== 'string') return str;
    return str.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
  };

  // Recursively sanitize object
  const sanitizeObject = (obj) => {
    for (const key in obj) {
      if (typeof obj[key] === 'string') {
        obj[key] = sanitizeString(obj[key]);
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        sanitizeObject(obj[key]);
      }
    }
  };

  if (req.body) {
    sanitizeObject(req.body);
  }

  next();
};

module.exports = {
  validationRules,
  handleValidationErrors,
  sanitizeInput
};