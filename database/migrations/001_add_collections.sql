-- Migration: Add Collections Tables
-- Description: Adds collections and place_collections tables to support collection functionality
-- Date: 2024-08-28

-- ================================
-- COLLECTIONS TABLE
-- ================================
CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_emoji VARCHAR(10) NOT NULL,
    color_hex VARCHAR(7), -- Hex color code like '#FF5733'
    user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- NULL for system collections
    is_system_generated BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================
-- PLACE_COLLECTIONS TABLE (Many-to-many relationship)
-- ================================
CREATE TABLE place_collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    added_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Who added this place to collection
    UNIQUE(place_id, collection_id)
);

-- ================================
-- COLLECTIONS INDEXES
-- ================================
CREATE INDEX idx_collections_user_id ON collections(user_id);
CREATE INDEX idx_collections_system ON collections(is_system_generated);
CREATE INDEX idx_collections_name ON collections USING gin(to_tsvector('english', name));

CREATE INDEX idx_place_collections_place_id ON place_collections(place_id);
CREATE INDEX idx_place_collections_collection_id ON place_collections(collection_id);
CREATE INDEX idx_place_collections_user_id ON place_collections(added_by_user_id);

-- ================================
-- COLLECTIONS TRIGGERS
-- ================================
CREATE TRIGGER update_collections_updated_at BEFORE UPDATE ON collections
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- ================================
-- INSERT SYSTEM COLLECTIONS
-- ================================

-- Insert system collections that replicate the current dynamic behavior
-- These are default collections that ensure every place has at least one collection
INSERT INTO collections (name, description, icon_emoji, color_hex, is_system_generated) VALUES 
('All Restaurants', 'Explore restaurants in your city', '🍽️', '#4CAF50', TRUE),
('All Museums', 'Discover art, history, and culture', '🏛️', '#9C27B0', TRUE),
('Italian Restaurants', 'Authentic Italian cuisine', '🍝', '#F44336', TRUE),
('Art Museums', 'Fine arts and exhibitions', '🎨', '#3F51B5', TRUE),
('Science Museums', 'Technology and interactive exhibits', '🔬', '#009688', TRUE),
('Uncategorized Places', 'Places that don''t fit other collections', '📍', '#757575', TRUE);

-- ================================
-- POPULATE PLACE_COLLECTIONS 
-- ================================

-- Add all restaurants to "All Restaurants" collection
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, c.id 
FROM places p, collections c 
WHERE p.type = 'restaurant' AND c.name = 'All Restaurants';

-- Add Italian restaurants to "Italian Restaurants" collection
-- This includes places with Italian cuisine in their special_data
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, c.id 
FROM places p, collections c 
WHERE p.type = 'restaurant' 
  AND (p.special_data->>'cuisine' ILIKE '%italian%' 
       OR p.name ILIKE '%italian%'
       OR p.name ILIKE '%pizza%'
       OR p.name ILIKE '%pasta%')
  AND c.name = 'Italian Restaurants';

-- Add all museums to "All Museums" collection
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, c.id 
FROM places p, collections c 
WHERE p.type = 'museum' AND c.name = 'All Museums';

-- Add art museums to "Art Museums" collection
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, c.id 
FROM places p, collections c 
WHERE p.type = 'museum' 
  AND (p.special_data->>'category' ILIKE '%art%'
       OR p.name ILIKE '%art%'
       OR p.name ILIKE '%kunst%')
  AND c.name = 'Art Museums';

-- Add science/technology museums to "Science Museums" collection
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, c.id 
FROM places p, collections c 
WHERE p.type = 'museum' 
  AND (p.special_data->>'category' ILIKE '%science%' 
       OR p.special_data->>'category' ILIKE '%technology%'
       OR p.name ILIKE '%science%'
       OR p.name ILIKE '%museum%' AND p.name ILIKE '%deutsch%')
  AND c.name = 'Science Museums';

-- ================================
-- FUNCTIONS AND TRIGGERS FOR COLLECTION CONSTRAINTS
-- ================================

-- Function to get default collection ID for a place type
CREATE OR REPLACE FUNCTION get_default_collection_for_place(place_type TEXT)
RETURNS UUID AS $$
DECLARE
    collection_id UUID;
BEGIN
    -- Get the appropriate default collection based on place type
    IF place_type = 'restaurant' THEN
        SELECT id INTO collection_id FROM collections WHERE name = 'All Restaurants' AND is_system_generated = TRUE;
    ELSIF place_type = 'museum' THEN
        SELECT id INTO collection_id FROM collections WHERE name = 'All Museums' AND is_system_generated = TRUE;
    ELSE
        -- Fallback to uncategorized
        SELECT id INTO collection_id FROM collections WHERE name = 'Uncategorized Places' AND is_system_generated = TRUE;
    END IF;
    
    RETURN collection_id;
END;
$$ LANGUAGE plpgsql;

-- Function to handle collection deletion and reassign places
CREATE OR REPLACE FUNCTION handle_collection_deletion()
RETURNS TRIGGER AS $$
DECLARE
    place_record RECORD;
    default_collection_id UUID;
    remaining_collections_count INTEGER;
BEGIN
    -- For each place that was only in this collection, move it to default collection
    FOR place_record IN 
        SELECT pc.place_id, p.type as place_type
        FROM place_collections pc
        JOIN places p ON pc.place_id = p.id
        WHERE pc.collection_id = OLD.id
    LOOP
        -- Check if this place has other collections
        SELECT COUNT(*) INTO remaining_collections_count
        FROM place_collections 
        WHERE place_id = place_record.place_id AND collection_id != OLD.id;
        
        -- If this was the only collection, move to default collection
        IF remaining_collections_count = 0 THEN
            default_collection_id := get_default_collection_for_place(place_record.place_type);
            
            -- Only insert if not already in default collection
            INSERT INTO place_collections (place_id, collection_id)
            SELECT place_record.place_id, default_collection_id
            WHERE NOT EXISTS (
                SELECT 1 FROM place_collections 
                WHERE place_id = place_record.place_id AND collection_id = default_collection_id
            );
        END IF;
    END LOOP;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger to handle collection deletion
CREATE TRIGGER before_collection_delete
    BEFORE DELETE ON collections
    FOR EACH ROW
    EXECUTE FUNCTION handle_collection_deletion();

-- Function to prevent removal of place from its last collection
CREATE OR REPLACE FUNCTION prevent_orphaned_places()
RETURNS TRIGGER AS $$
DECLARE
    remaining_collections INTEGER;
BEGIN
    -- Count remaining collections for this place after removal
    SELECT COUNT(*) INTO remaining_collections
    FROM place_collections
    WHERE place_id = OLD.place_id AND collection_id != OLD.collection_id;
    
    -- If this would be the last collection, prevent deletion
    IF remaining_collections = 0 THEN
        RAISE EXCEPTION 'Cannot remove place from its only collection. Place must belong to at least one collection.';
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger to prevent orphaned places
CREATE TRIGGER before_place_collection_delete
    BEFORE DELETE ON place_collections
    FOR EACH ROW
    EXECUTE FUNCTION prevent_orphaned_places();