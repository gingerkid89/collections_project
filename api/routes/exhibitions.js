// routes/exhibitions.js - Exhibitions endpoints
const express = require('express');
const pool = require('../database');
const router = express.Router();

// GET /api/v1/exhibitions - Get all exhibitions with optional filtering
router.get('/', async (req, res) => {
  try {
    const { museumId, type, category, isActive, limit, offset } = req.query;
    
    let query = `
      SELECT 
        e.*,
        p.name as museum_name,
        p.address as museum_address,
        p.emoji as museum_emoji
      FROM exhibitions e
      JOIN places p ON e.museum_id = p.id
    `;
    
    const conditions = [];
    const values = [];
    let paramCount = 0;
    
    if (museumId) {
      paramCount++;
      conditions.push(`e.museum_id = $${paramCount}`);
      values.push(museumId);
    }
    
    if (type) {
      paramCount++;
      conditions.push(`e.exhibition_type = $${paramCount}`);
      values.push(type);
    }
    
    if (category) {
      paramCount++;
      conditions.push(`e.category = $${paramCount}`);
      values.push(category);
    }
    
    if (isActive !== undefined) {
      paramCount++;
      conditions.push(`e.is_active = $${paramCount}`);
      values.push(isActive === 'true');
    }
    
    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }
    
    query += `
      ORDER BY 
        e.exhibition_type DESC, -- permanent first, then temporary, then special
        e.start_date ASC NULLS FIRST,
        e.name ASC
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
    
    const exhibitions = result.rows.map(row => ({
      id: row.id,
      museumId: row.museum_id,
      museumName: row.museum_name,
      museumAddress: row.museum_address,
      museumEmoji: row.museum_emoji,
      name: row.name,
      description: row.description,
      exhibitionType: row.exhibition_type,
      startDate: row.start_date,
      endDate: row.end_date,
      artist: row.artist,
      period: row.period,
      category: row.category,
      isActive: row.is_active,
      ticketRequired: row.ticket_required,
      additionalCost: row.additional_cost,
      imageUrl: row.image_url,
      websiteUrl: row.website_url,
      duration: row.start_date && row.end_date 
        ? `${row.start_date} bis ${row.end_date}`
        : row.exhibition_type === 'permanent' 
        ? 'Dauerausstellung'
        : 'Laufzeit offen',
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));
    
    res.json({
      success: true,
      data: exhibitions,
      count: exhibitions.length,
      filters: { museumId, type, category, isActive, limit, offset }
    });
    
  } catch (error) {
    console.error('Error fetching exhibitions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch exhibitions',
      message: error.message
    });
  }
});

// GET /api/v1/exhibitions/:id - Get single exhibition with detailed information
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const query = `
      SELECT 
        e.*,
        p.name as museum_name,
        p.address as museum_address,
        p.emoji as museum_emoji,
        p.phone as museum_phone,
        p.website as museum_website,
        p.opening_hours as museum_opening_hours
      FROM exhibitions e
      JOIN places p ON e.museum_id = p.id
      WHERE e.id = $1
    `;
    
    const result = await pool.query(query, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Exhibition not found'
      });
    }
    
    const row = result.rows[0];
    
    // Get related exhibitions from same museum
    const relatedQuery = `
      SELECT id, name, exhibition_type, category, start_date, end_date
      FROM exhibitions 
      WHERE museum_id = $1 AND id != $2 AND is_active = true
      ORDER BY exhibition_type, name
      LIMIT 5
    `;
    
    const relatedResult = await pool.query(relatedQuery, [row.museum_id, id]);
    
    res.json({
      success: true,
      data: {
        id: row.id,
        museumId: row.museum_id,
        museum: {
          name: row.museum_name,
          address: row.museum_address,
          emoji: row.museum_emoji,
          phone: row.museum_phone,
          website: row.museum_website,
          openingHours: row.museum_opening_hours
        },
        name: row.name,
        description: row.description,
        exhibitionType: row.exhibition_type,
        startDate: row.start_date,
        endDate: row.end_date,
        artist: row.artist,
        period: row.period,
        category: row.category,
        isActive: row.is_active,
        ticketRequired: row.ticket_required,
        additionalCost: row.additional_cost,
        imageUrl: row.image_url,
        websiteUrl: row.website_url,
        duration: row.start_date && row.end_date 
          ? `${row.start_date} bis ${row.end_date}`
          : row.exhibition_type === 'permanent' 
          ? 'Dauerausstellung'
          : 'Laufzeit offen',
        relatedExhibitions: relatedResult.rows,
        createdAt: row.created_at,
        updatedAt: row.updated_at
      }
    });
    
  } catch (error) {
    console.error('Error fetching exhibition:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch exhibition',
      message: error.message
    });
  }
});

// GET /api/v1/exhibitions/museum/:museumId - Get all exhibitions for a specific museum
router.get('/museum/:museumId', async (req, res) => {
  try {
    const { museumId } = req.params;
    const { type, isActive = 'true' } = req.query;
    
    // Verify museum exists
    const museumResult = await pool.query(
      'SELECT name, type FROM places WHERE id = $1',
      [museumId]
    );
    
    if (museumResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Museum not found'
      });
    }
    
    if (museumResult.rows[0].type !== 'museum') {
      return res.status(400).json({
        success: false,
        error: 'This endpoint is only for museums'
      });
    }
    
    let query = `
      SELECT *
      FROM exhibitions 
      WHERE museum_id = $1
    `;
    
    const conditions = [];
    const values = [museumId];
    let paramCount = 1;
    
    if (type) {
      paramCount++;
      conditions.push(`exhibition_type = $${paramCount}`);
      values.push(type);
    }
    
    if (isActive !== undefined) {
      paramCount++;
      conditions.push(`is_active = $${paramCount}`);
      values.push(isActive === 'true');
    }
    
    if (conditions.length > 0) {
      query += ` AND ${conditions.join(' AND ')}`;
    }
    
    query += `
      ORDER BY 
        CASE exhibition_type 
          WHEN 'permanent' THEN 1 
          WHEN 'temporary' THEN 2 
          WHEN 'special' THEN 3 
        END,
        name ASC
    `;
    
    const result = await pool.query(query, values);
    
    // Group by exhibition type
    const exhibitionsByType = {
      permanent: [],
      temporary: [],
      special: []
    };
    
    result.rows.forEach(row => {
      const exhibition = {
        id: row.id,
        name: row.name,
        description: row.description,
        exhibitionType: row.exhibition_type,
        startDate: row.start_date,
        endDate: row.end_date,
        artist: row.artist,
        period: row.period,
        category: row.category,
        isActive: row.is_active,
        ticketRequired: row.ticket_required,
        additionalCost: row.additional_cost,
        imageUrl: row.image_url,
        websiteUrl: row.website_url,
        duration: row.start_date && row.end_date 
          ? `${row.start_date} bis ${row.end_date}`
          : row.exhibition_type === 'permanent' 
          ? 'Dauerausstellung'
          : 'Laufzeit offen',
        createdAt: row.created_at,
        updatedAt: row.updated_at
      };
      
      exhibitionsByType[row.exhibition_type].push(exhibition);
    });
    
    res.json({
      success: true,
      data: {
        museumId,
        museumName: museumResult.rows[0].name,
        exhibitions: result.rows,
        exhibitionsByType,
        totalExhibitions: result.rows.length,
        counts: {
          permanent: exhibitionsByType.permanent.length,
          temporary: exhibitionsByType.temporary.length,
          special: exhibitionsByType.special.length
        }
      }
    });
    
  } catch (error) {
    console.error('Error fetching museum exhibitions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch museum exhibitions',
      message: error.message
    });
  }
});

module.exports = router;