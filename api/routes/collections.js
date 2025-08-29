// routes/collections.js - Collections management endpoints
const express = require('express');
const { Pool } = require('pg');
const router = express.Router();

// Database connection
const pool = new Pool({
  user: process.env.DB_USER || 'collections_user',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'collections_app',
  password: process.env.DB_PASSWORD || 'password123',
  port: process.env.DB_PORT || 5433,
});

// ================================
// GET /api/v1/collections - Get all collections with place counts
// ================================
router.get('/', async (req, res) => {
  try {
    const query = `
      SELECT 
        c.id,
        c.name,
        c.description,
        c.icon_emoji,
        c.color_hex,
        c.is_system_generated,
        c.created_at,
        COUNT(pc.place_id) as place_count,
        COUNT(CASE WHEN ups.is_visited = true THEN 1 END) as visited_count
      FROM collections c
      LEFT JOIN place_collections pc ON c.id = pc.collection_id
      LEFT JOIN user_place_status ups ON pc.place_id = ups.place_id 
        AND ups.user_id = $1
      GROUP BY c.id, c.name, c.description, c.icon_emoji, c.color_hex, c.is_system_generated, c.created_at
      ORDER BY c.is_system_generated DESC, c.name ASC
    `;
    
    // For now, use hardcoded user ID - in production, get from auth token
    const userId = req.query.user_id || '00000000-0000-0000-0000-000000000000';
    
    const result = await pool.query(query, [userId]);
    
    const collections = result.rows.map(row => ({
      id: row.id,
      name: row.name,
      description: row.description,
      iconEmoji: row.icon_emoji,
      colorHex: row.color_hex,
      isSystemGenerated: row.is_system_generated,
      totalCount: parseInt(row.place_count),
      visitedCount: parseInt(row.visited_count),
      createdAt: row.created_at
    }));

    res.json({
      success: true,
      data: collections,
      count: collections.length
    });

  } catch (error) {
    console.error('Error fetching collections:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ================================
// GET /api/v1/collections/:id - Get single collection with details
// ================================
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.query.user_id || '00000000-0000-0000-0000-000000000000';

    const query = `
      SELECT 
        c.id,
        c.name,
        c.description,
        c.icon_emoji,
        c.color_hex,
        c.is_system_generated,
        c.created_at,
        COUNT(pc.place_id) as place_count,
        COUNT(CASE WHEN ups.is_visited = true THEN 1 END) as visited_count
      FROM collections c
      LEFT JOIN place_collections pc ON c.id = pc.collection_id
      LEFT JOIN user_place_status ups ON pc.place_id = ups.place_id 
        AND ups.user_id = $2
      WHERE c.id = $1
      GROUP BY c.id, c.name, c.description, c.icon_emoji, c.color_hex, c.is_system_generated, c.created_at
    `;

    const result = await pool.query(query, [id, userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Collection not found'
      });
    }

    const row = result.rows[0];
    const collection = {
      id: row.id,
      name: row.name,
      description: row.description,
      iconEmoji: row.icon_emoji,
      colorHex: row.color_hex,
      isSystemGenerated: row.is_system_generated,
      totalCount: parseInt(row.place_count),
      visitedCount: parseInt(row.visited_count),
      createdAt: row.created_at
    };

    res.json({
      success: true,
      data: collection
    });

  } catch (error) {
    console.error('Error fetching collection:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ================================
// GET /api/v1/collections/:id/places - Get places in a specific collection
// ================================
router.get('/:id/places', async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.query.user_id || '00000000-0000-0000-0000-000000000000';

    // First verify collection exists
    const collectionCheck = await pool.query('SELECT id FROM collections WHERE id = $1', [id]);
    if (collectionCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Collection not found'
      });
    }

    const query = `
      SELECT 
        p.id,
        p.name,
        p.type,
        p.emoji,
        p.address,
        p.phone,
        p.website,
        p.email,
        p.opening_hours,
        p.highlights,
        p.price_range,
        p.latitude,
        p.longitude,
        p.image_url,
        p.special_data,
        p.created_at,
        p.updated_at,
        COALESCE(ups.is_visited, false) as is_visited,
        ups.user_rating,
        ups.visit_count,
        ups.last_visit
      FROM places p
      INNER JOIN place_collections pc ON p.id = pc.place_id
      LEFT JOIN user_place_status ups ON p.id = ups.place_id AND ups.user_id = $2
      WHERE pc.collection_id = $1
      ORDER BY p.name ASC
    `;

    const result = await pool.query(query, [id, userId]);

    const places = result.rows.map(row => ({
      id: row.id,
      name: row.name,
      type: row.type,
      emoji: row.emoji,
      imageUrl: row.image_url,
      latitude: row.latitude ? parseFloat(row.latitude) : null,
      longitude: row.longitude ? parseFloat(row.longitude) : null,
      info: {
        address: row.address,
        phone: row.phone,
        website: row.website,
        email: row.email,
        openingHours: row.opening_hours || {},
        highlights: row.highlights || [],
        priceRange: row.price_range
      },
      collectionStatus: {
        isVisited: row.is_visited,
        userRating: row.user_rating ? parseFloat(row.user_rating) : null,
        visitCount: row.visit_count || 0,
        lastVisit: row.last_visit
      },
      specialData: row.special_data || {},
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));

    res.json({
      success: true,
      data: places,
      count: places.length,
      collectionId: id
    });

  } catch (error) {
    console.error('Error fetching collection places:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ================================
// POST /api/v1/collections - Create new collection (future feature)
// ================================
router.post('/', async (req, res) => {
  try {
    const { name, description, iconEmoji, colorHex, userId } = req.body;

    if (!name || !iconEmoji) {
      return res.status(400).json({
        success: false,
        message: 'Name and icon emoji are required'
      });
    }

    const query = `
      INSERT INTO collections (name, description, icon_emoji, color_hex, user_id, is_system_generated)
      VALUES ($1, $2, $3, $4, $5, false)
      RETURNING id, name, description, icon_emoji, color_hex, created_at
    `;

    const result = await pool.query(query, [
      name,
      description || null,
      iconEmoji,
      colorHex || '#2196F3',
      userId || null
    ]);

    const collection = {
      id: result.rows[0].id,
      name: result.rows[0].name,
      description: result.rows[0].description,
      iconEmoji: result.rows[0].icon_emoji,
      colorHex: result.rows[0].color_hex,
      isSystemGenerated: false,
      totalCount: 0,
      visitedCount: 0,
      createdAt: result.rows[0].created_at
    };

    res.status(201).json({
      success: true,
      data: collection,
      message: 'Collection created successfully'
    });

  } catch (error) {
    console.error('Error creating collection:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;