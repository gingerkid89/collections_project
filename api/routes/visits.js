// routes/visits.js - Visits endpoints
const express = require('express');
const pool = require('../database');
const router = express.Router();

// GET /api/v1/visits - Get visits with optional filtering
router.get('/', async (req, res) => {
  try {
    const { userId, placeId, placeType, limit, offset, isPublic } = req.query;
    
    let query = `
      SELECT 
        v.*,
        p.name as place_name,
        p.type as place_type,
        p.emoji as place_emoji,
        p.address as place_address,
        u.display_name as user_name,
        COUNT(va.id) as activities_count
      FROM visits v
      JOIN places p ON v.place_id = p.id
      LEFT JOIN users u ON v.user_id = u.id
      LEFT JOIN visit_activities va ON v.id = va.visit_id
    `;
    
    const conditions = [];
    const values = [];
    let paramCount = 0;
    
    if (userId) {
      paramCount++;
      conditions.push(`v.user_id = $${paramCount}`);
      values.push(userId);
    }
    
    if (placeId) {
      paramCount++;
      conditions.push(`v.place_id = $${paramCount}`);
      values.push(placeId);
    }
    
    if (placeType) {
      paramCount++;
      conditions.push(`v.place_type = $${paramCount}`);
      values.push(placeType);
    }
    
    if (isPublic !== undefined) {
      paramCount++;
      conditions.push(`v.is_public = $${paramCount}`);
      values.push(isPublic === 'true');
    }
    
    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }
    
    query += `
      GROUP BY v.id, p.name, p.type, p.emoji, p.address, u.display_name
      ORDER BY v.date DESC
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
    
    const visits = result.rows.map(row => ({
      id: row.id,
      userId: row.user_id,
      userName: row.user_name,
      placeId: row.place_id,
      placeName: row.place_name,
      placeType: row.place_type,
      placeEmoji: row.place_emoji,
      placeAddress: row.place_address,
      date: row.date,
      overallRating: row.overall_rating,
      notes: row.notes,
      durationMinutes: row.duration_minutes,
      totalCost: row.total_cost,
      metadata: row.metadata,
      photoUrls: row.photo_urls,
      isPublic: row.is_public,
      activitiesCount: parseInt(row.activities_count) || 0,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));
    
    res.json({
      success: true,
      data: visits,
      count: visits.length,
      filters: { userId, placeId, placeType, isPublic, limit, offset }
    });
    
  } catch (error) {
    console.error('Error fetching visits:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch visits',
      message: error.message
    });
  }
});

// GET /api/v1/visits/:id - Get single visit with activities
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get visit details
    const visitResult = await pool.query(
      `SELECT 
        v.*,
        p.name as place_name,
        p.type as place_type,
        p.emoji as place_emoji,
        p.address as place_address,
        u.display_name as user_name
       FROM visits v
       JOIN places p ON v.place_id = p.id
       LEFT JOIN users u ON v.user_id = u.id
       WHERE v.id = $1`,
      [id]
    );
    
    if (visitResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Visit not found'
      });
    }
    
    const visit = visitResult.rows[0];
    
    // Get visit activities
    const activitiesResult = await pool.query(
      `SELECT * FROM visit_activities WHERE visit_id = $1 ORDER BY created_at`,
      [id]
    );
    
    res.json({
      success: true,
      data: {
        id: visit.id,
        userId: visit.user_id,
        userName: visit.user_name,
        placeId: visit.place_id,
        placeName: visit.place_name,
        placeType: visit.place_type,
        placeEmoji: visit.place_emoji,
        placeAddress: visit.place_address,
        date: visit.date,
        overallRating: visit.overall_rating,
        notes: visit.notes,
        durationMinutes: visit.duration_minutes,
        totalCost: visit.total_cost,
        metadata: visit.metadata,
        photoUrls: visit.photo_urls,
        isPublic: visit.is_public,
        activities: activitiesResult.rows,
        createdAt: visit.created_at,
        updatedAt: visit.updated_at
      }
    });
    
  } catch (error) {
    console.error('Error fetching visit:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch visit',
      message: error.message
    });
  }
});

// POST /api/v1/visits - Create new visit
router.post('/', async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const {
      userId,
      placeId,
      date,
      placeType,
      overallRating,
      notes,
      durationMinutes,
      totalCost,
      metadata = {},
      photoUrls = [],
      isPublic = true,
      activities = []
    } = req.body;
    
    // Validate required fields
    if (!userId || !placeId || !date || !placeType) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: userId, placeId, date, placeType'
      });
    }
    
    // Verify place exists
    const placeResult = await client.query(
      'SELECT id, type FROM places WHERE id = $1',
      [placeId]
    );
    
    if (placeResult.rows.length === 0) {
      throw new Error('Place not found');
    }
    
    if (placeResult.rows[0].type !== placeType) {
      throw new Error('Place type mismatch');
    }
    
    // Create visit
    const visitResult = await client.query(
      `INSERT INTO visits (
        user_id, place_id, date, place_type, overall_rating, notes,
        duration_minutes, total_cost, metadata, photo_urls, is_public
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *`,
      [userId, placeId, date, placeType, overallRating, notes, 
       durationMinutes, totalCost, JSON.stringify(metadata), photoUrls, isPublic]
    );
    
    const visit = visitResult.rows[0];
    
    // Create visit activities
    const createdActivities = [];
    for (const activity of activities) {
      const activityResult = await client.query(
        `INSERT INTO visit_activities (visit_id, name, type, rating, activity_data)
         VALUES ($1, $2, $3, $4, $5) RETURNING *`,
        [visit.id, activity.name, activity.type, activity.rating, JSON.stringify(activity.activityData || {})]
      );
      createdActivities.push(activityResult.rows[0]);
    }
    
    // Update user place status
    await client.query(
      `INSERT INTO user_place_status (user_id, place_id, is_visited, last_visit, visit_count, user_rating)
       VALUES ($1, $2, true, $3, 1, $4)
       ON CONFLICT (user_id, place_id)
       DO UPDATE SET
         is_visited = true,
         last_visit = GREATEST(user_place_status.last_visit, EXCLUDED.last_visit),
         visit_count = user_place_status.visit_count + 1,
         user_rating = COALESCE(EXCLUDED.user_rating, user_place_status.user_rating),
         updated_at = NOW()`,
      [userId, placeId, date, overallRating]
    );
    
    await client.query('COMMIT');
    
    res.status(201).json({
      success: true,
      data: {
        ...visit,
        activities: createdActivities
      },
      message: 'Visit created successfully'
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error creating visit:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create visit',
      message: error.message
    });
  } finally {
    client.release();
  }
});

module.exports = router;