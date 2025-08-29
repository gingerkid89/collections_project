// routes/places.js - Places endpoints (restaurants and museums)
const express = require('express');
const pool = require('../database');
const router = express.Router();

// GET /api/v1/places - Get all places with optional filtering
router.get('/', async (req, res) => {
  try {
    const { type, limit, offset, search } = req.query;
    
    let query = `
      SELECT 
        p.*,
        COUNT(DISTINCT m.id) as menu_items_count,
        COUNT(DISTINCT e.id) as exhibitions_count,
        AVG(ups.user_rating) as average_rating,
        COUNT(DISTINCT ups.id) as total_ratings
      FROM places p
      LEFT JOIN menu_items m ON p.id = m.place_id
      LEFT JOIN exhibitions e ON p.id = e.museum_id AND e.is_active = true
      LEFT JOIN user_place_status ups ON p.id = ups.place_id AND ups.user_rating IS NOT NULL
    `;
    
    const conditions = [];
    const values = [];
    let paramCount = 0;
    
    if (type) {
      paramCount++;
      conditions.push(`p.type = $${paramCount}`);
      values.push(type);
    }
    
    if (search) {
      paramCount++;
      conditions.push(`(p.name ILIKE $${paramCount} OR p.address ILIKE $${paramCount})`);
      values.push(`%${search}%`);
    }
    
    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }
    
    query += ` 
      GROUP BY p.id, p.name, p.type, p.emoji, p.address, p.phone, p.website, p.email, 
               p.opening_hours, p.highlights, p.price_range, p.special_data, p.image_url, p.created_at, p.updated_at
      ORDER BY p.name
    `;
    
    if (limit) {
      paramCount++;
      query += ` LIMIT $${paramCount}`;
      values.push(parseInt(limit));
    }
    
    if (offset) {
      paramCount++;
      query += ` OFFSET $${paramCount}`;
      values.push(parseInt(offset));
    }
    
    const result = await pool.query(query, values);
    
    const places = result.rows.map(row => ({
      id: row.id,
      name: row.name,
      type: row.type,
      emoji: row.emoji,
      address: row.address,
      phone: row.phone,
      website: row.website,
      email: row.email,
      openingHours: row.opening_hours,
      highlights: row.highlights,
      priceRange: row.price_range,
      latitude: row.latitude ? parseFloat(row.latitude) : null,
      longitude: row.longitude ? parseFloat(row.longitude) : null,
      imageUrl: row.image_url,
      specialData: row.special_data,
      stats: {
        menuItemsCount: parseInt(row.menu_items_count) || 0,
        exhibitionsCount: parseInt(row.exhibitions_count) || 0,
        averageRating: row.average_rating ? parseFloat(row.average_rating).toFixed(1) : null,
        totalRatings: parseInt(row.total_ratings) || 0
      },
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));
    
    res.json({
      success: true,
      data: places,
      count: places.length,
      filters: { type, search, limit, offset }
    });
    
  } catch (error) {
    console.error('Error fetching places:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch places',
      message: error.message
    });
  }
});

// GET /api/v1/places/:id - Get single place with detailed information
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get place details
    const placeResult = await pool.query(
      'SELECT * FROM places WHERE id = $1',
      [id]
    );
    
    if (placeResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Place not found'
      });
    }
    
    const place = placeResult.rows[0];
    
    // Get additional data based on place type
    let additionalData = {};
    
    if (place.type === 'restaurant') {
      // Get menu items
      const menuResult = await pool.query(
        `SELECT * FROM menu_items WHERE place_id = $1 ORDER BY category, name`,
        [id]
      );
      additionalData.menu = menuResult.rows;
    } else if (place.type === 'museum') {
      // Get exhibitions
      const exhibitionsResult = await pool.query(
        `SELECT * FROM exhibitions WHERE museum_id = $1 AND is_active = true ORDER BY exhibition_type, name`,
        [id]
      );
      additionalData.exhibitions = exhibitionsResult.rows;
    }
    
    // Get visit statistics
    const statsResult = await pool.query(
      `SELECT 
        COUNT(DISTINCT v.id) as total_visits,
        COUNT(DISTINCT ups.id) as total_ratings,
        AVG(ups.user_rating) as average_rating,
        COUNT(DISTINCT CASE WHEN ups.is_visited = true THEN ups.user_id END) as unique_visitors
       FROM places p
       LEFT JOIN visits v ON p.id = v.place_id
       LEFT JOIN user_place_status ups ON p.id = ups.place_id
       WHERE p.id = $1`,
      [id]
    );
    
    const stats = statsResult.rows[0];
    
    res.json({
      success: true,
      data: {
        id: place.id,
        name: place.name,
        type: place.type,
        emoji: place.emoji,
        address: place.address,
        phone: place.phone,
        website: place.website,
        email: place.email,
        openingHours: place.opening_hours,
        highlights: place.highlights,
        priceRange: place.price_range,
        latitude: place.latitude ? parseFloat(place.latitude) : null,
        longitude: place.longitude ? parseFloat(place.longitude) : null,
        imageUrl: place.image_url,
        specialData: place.special_data,
        ...additionalData,
        stats: {
          totalVisits: parseInt(stats.total_visits) || 0,
          totalRatings: parseInt(stats.total_ratings) || 0,
          averageRating: stats.average_rating ? parseFloat(stats.average_rating).toFixed(1) : null,
          uniqueVisitors: parseInt(stats.unique_visitors) || 0
        },
        createdAt: place.created_at,
        updatedAt: place.updated_at
      }
    });
    
  } catch (error) {
    console.error('Error fetching place:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch place',
      message: error.message
    });
  }
});

// GET /api/v1/places/:id/menu - Get menu items for a restaurant
router.get('/:id/menu', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verify place exists and is a restaurant
    const placeResult = await pool.query(
      'SELECT type FROM places WHERE id = $1',
      [id]
    );
    
    if (placeResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Place not found'
      });
    }
    
    if (placeResult.rows[0].type !== 'restaurant') {
      return res.status(400).json({
        success: false,
        error: 'This endpoint is only for restaurants'
      });
    }
    
    // Get menu items
    const menuResult = await pool.query(
      `SELECT 
        id, name, description, price, category, 
        allergens, is_vegetarian, is_vegan, is_gluten_free,
        image_url, created_at, updated_at
       FROM menu_items 
       WHERE place_id = $1 
       ORDER BY category, name`,
      [id]
    );
    
    // Group by category
    const menuByCategory = {};
    menuResult.rows.forEach(item => {
      if (!menuByCategory[item.category]) {
        menuByCategory[item.category] = [];
      }
      menuByCategory[item.category].push(item);
    });
    
    res.json({
      success: true,
      data: {
        placeId: id,
        menuItems: menuResult.rows,
        menuByCategory,
        totalItems: menuResult.rows.length,
        categories: Object.keys(menuByCategory)
      }
    });
    
  } catch (error) {
    console.error('Error fetching menu:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch menu',
      message: error.message
    });
  }
});

// POST /api/v1/places - Create a new place (restaurant or museum)
router.post('/', async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const {
      name,
      type,
      emoji,
      address,
      phone,
      website,
      email,
      openingHours,
      highlights,
      priceRange,
      latitude,
      longitude,
      imageUrl,
      specialData,
      menuItems
    } = req.body;
    
    // Validate required fields
    if (!name || !type || !address) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: name, type, and address are required'
      });
    }
    
    // Validate place type
    if (!['restaurant', 'museum'].includes(type)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid place type. Must be "restaurant" or "museum"'
      });
    }
    
    // Insert the place
    const placeResult = await client.query(`
      INSERT INTO places (
        name, type, emoji, address, phone, website, email,
        opening_hours, highlights, price_range, latitude, longitude,
        image_url, special_data, created_at, updated_at
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, NOW(), NOW()
      ) RETURNING *
    `, [
      name,
      type,
      emoji || (type === 'restaurant' ? '🍽️' : '🏛️'),
      address,
      phone || null,
      website || null,
      email || null,
      openingHours || {},
      highlights || [],
      priceRange || null,
      latitude ? parseFloat(latitude) : null,
      longitude ? parseFloat(longitude) : null,
      imageUrl || null,
      specialData || {},
    ]);
    
    const createdPlace = placeResult.rows[0];
    
    // If it's a restaurant and has menu items, insert them
    if (type === 'restaurant' && menuItems && Array.isArray(menuItems) && menuItems.length > 0) {
      for (const item of menuItems) {
        await client.query(`
          INSERT INTO menu_items (
            place_id, name, description, price, category,
            allergens, is_vegetarian, is_vegan, is_gluten_free,
            image_url, created_at, updated_at
          ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW()
          )
        `, [
          createdPlace.id,
          item.name,
          item.description || null,
          parseFloat(item.price),
          item.category || 'Main Dishes',
          item.allergens || [],
          item.isVegetarian || false,
          item.isVegan || false,
          item.isGlutenFree || false,
          item.imageUrl || null
        ]);
      }
    }
    
    await client.query('COMMIT');
    
    // Return the created place with the same format as GET endpoints
    res.status(201).json({
      success: true,
      data: {
        id: createdPlace.id,
        name: createdPlace.name,
        type: createdPlace.type,
        emoji: createdPlace.emoji,
        address: createdPlace.address,
        phone: createdPlace.phone,
        website: createdPlace.website,
        email: createdPlace.email,
        openingHours: createdPlace.opening_hours,
        highlights: createdPlace.highlights,
        priceRange: createdPlace.price_range,
        latitude: createdPlace.latitude ? parseFloat(createdPlace.latitude) : null,
        longitude: createdPlace.longitude ? parseFloat(createdPlace.longitude) : null,
        imageUrl: createdPlace.image_url,
        specialData: createdPlace.special_data,
        stats: {
          menuItemsCount: menuItems ? menuItems.length : 0,
          exhibitionsCount: 0,
          averageRating: null,
          totalRatings: 0
        },
        createdAt: createdPlace.created_at,
        updatedAt: createdPlace.updated_at
      },
      message: `${type.charAt(0).toUpperCase() + type.slice(1)} created successfully`
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error creating place:', error);
    
    res.status(500).json({
      success: false,
      error: 'Failed to create place',
      message: error.message
    });
  } finally {
    client.release();
  }
});

module.exports = router;