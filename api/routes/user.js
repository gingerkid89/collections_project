// routes/user.js - User-specific endpoints
const express = require('express');
const pool = require('../database');
const router = express.Router();

// GET /api/v1/user/:userId/places - Get user's places with collection status
router.get('/:userId/places', async (req, res) => {
  try {
    const { userId } = req.params;
    const { type, visited, limit, offset } = req.query;
    
    let query = `
      SELECT 
        p.*,
        ups.is_visited,
        ups.last_visit,
        ups.user_rating,
        ups.visit_count,
        COUNT(DISTINCT v.id) as total_visits,
        COUNT(DISTINCT CASE WHEN p.type = 'restaurant' THEN m.id END) as menu_items_count,
        COUNT(DISTINCT CASE WHEN p.type = 'museum' THEN e.id END) as exhibitions_count
      FROM places p
      LEFT JOIN user_place_status ups ON p.id = ups.place_id AND ups.user_id = $1
      LEFT JOIN visits v ON p.id = v.place_id AND v.user_id = $1
      LEFT JOIN menu_items m ON p.id = m.place_id
      LEFT JOIN exhibitions e ON p.id = e.museum_id AND e.is_active = true
    `;
    
    const conditions = [`1 = 1`]; // Always true condition for easier query building
    const values = [userId];
    let paramCount = 1;
    
    if (type) {
      paramCount++;
      conditions.push(`p.type = $${paramCount}`);
      values.push(type);
    }
    
    if (visited !== undefined) {
      paramCount++;
      conditions.push(`COALESCE(ups.is_visited, false) = $${paramCount}`);
      values.push(visited === 'true');
    }
    
    query += ` WHERE ${conditions.join(' AND ')}`;
    
    query += `
      GROUP BY p.id, p.name, p.type, p.emoji, p.address, p.phone, p.website, p.email,
               p.opening_hours, p.highlights, p.price_range, p.special_data, p.created_at, p.updated_at,
               ups.is_visited, ups.last_visit, ups.user_rating, ups.visit_count
      ORDER BY 
        CASE WHEN ups.is_visited = true THEN ups.last_visit END DESC NULLS LAST,
        p.name
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
    
    const userPlaces = result.rows.map(row => ({
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
      specialData: row.special_data,
      collectionStatus: {
        isVisited: row.is_visited || false,
        lastVisit: row.last_visit,
        userRating: row.user_rating,
        visitCount: row.visit_count || 0
      },
      stats: {
        totalVisits: parseInt(row.total_visits) || 0,
        menuItemsCount: parseInt(row.menu_items_count) || 0,
        exhibitionsCount: parseInt(row.exhibitions_count) || 0
      },
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));
    
    res.json({
      success: true,
      data: userPlaces,
      count: userPlaces.length,
      filters: { userId, type, visited, limit, offset }
    });
    
  } catch (error) {
    console.error('Error fetching user places:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user places',
      message: error.message
    });
  }
});

// GET /api/v1/user/:userId/favorites - Get user's favorite places (most visited)
router.get('/:userId/favorites', async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 10 } = req.query;
    
    const query = `
      SELECT 
        p.*,
        ups.visit_count,
        ups.user_rating,
        ups.last_visit,
        COUNT(DISTINCT v.id) as total_visits,
        AVG(v.overall_rating) as average_visit_rating
      FROM places p
      JOIN user_place_status ups ON p.id = ups.place_id AND ups.user_id = $1
      LEFT JOIN visits v ON p.id = v.place_id AND v.user_id = $1
      WHERE ups.is_visited = true AND ups.visit_count > 0
      GROUP BY p.id, p.name, p.type, p.emoji, p.address, p.phone, p.website, p.email,
               p.opening_hours, p.highlights, p.price_range, p.special_data, p.created_at, p.updated_at,
               ups.visit_count, ups.user_rating, ups.last_visit
      ORDER BY ups.visit_count DESC, ups.last_visit DESC
      LIMIT $2
    `;
    
    const result = await pool.query(query, [userId, parseInt(limit)]);
    
    const favorites = result.rows.map(row => ({
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
      specialData: row.special_data,
      favoriteStats: {
        visitCount: row.visit_count,
        userRating: row.user_rating,
        lastVisit: row.last_visit,
        totalVisits: parseInt(row.total_visits) || 0,
        averageVisitRating: row.average_visit_rating ? parseFloat(row.average_visit_rating).toFixed(1) : null
      },
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));
    
    res.json({
      success: true,
      data: favorites,
      count: favorites.length,
      userId
    });
    
  } catch (error) {
    console.error('Error fetching user favorites:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user favorites',
      message: error.message
    });
  }
});

// GET /api/v1/user/:userId/stats - Get user statistics
router.get('/:userId/stats', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const statsQuery = `
      SELECT 
        COUNT(DISTINCT CASE WHEN ups.is_visited = true THEN p.id END) as places_visited,
        COUNT(DISTINCT CASE WHEN ups.is_visited = true AND p.type = 'restaurant' THEN p.id END) as restaurants_visited,
        COUNT(DISTINCT CASE WHEN ups.is_visited = true AND p.type = 'museum' THEN p.id END) as museums_visited,
        COUNT(DISTINCT v.id) as total_visits,
        AVG(v.overall_rating) as average_rating,
        SUM(v.total_cost) as total_spent,
        SUM(v.duration_minutes) as total_time_minutes,
        MAX(v.date) as last_visit_date,
        COUNT(DISTINCT va.id) as total_activities
      FROM users u
      LEFT JOIN user_place_status ups ON u.id = ups.user_id
      LEFT JOIN places p ON ups.place_id = p.id
      LEFT JOIN visits v ON u.id = v.user_id
      LEFT JOIN visit_activities va ON v.id = va.visit_id
      WHERE u.id = $1
      GROUP BY u.id
    `;
    
    const result = await pool.query(statsQuery, [userId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }
    
    const stats = result.rows[0];
    
    res.json({
      success: true,
      data: {
        userId,
        placesVisited: parseInt(stats.places_visited) || 0,
        restaurantsVisited: parseInt(stats.restaurants_visited) || 0,
        museumsVisited: parseInt(stats.museums_visited) || 0,
        totalVisits: parseInt(stats.total_visits) || 0,
        averageRating: stats.average_rating ? parseFloat(stats.average_rating).toFixed(1) : null,
        totalSpent: stats.total_spent ? parseFloat(stats.total_spent).toFixed(2) : '0.00',
        totalTimeHours: stats.total_time_minutes ? Math.round(stats.total_time_minutes / 60 * 10) / 10 : 0,
        lastVisitDate: stats.last_visit_date,
        totalActivities: parseInt(stats.total_activities) || 0
      }
    });
    
  } catch (error) {
    console.error('Error fetching user stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user statistics',
      message: error.message
    });
  }
});

module.exports = router;