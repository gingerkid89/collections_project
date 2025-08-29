-- Collections App Database Schema
-- Based on Flutter models: Place, Restaurant, Museum, Visit, etc.

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================
-- USERS TABLE
-- ================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================
-- PLACES TABLE (Base for all place types)
-- ================================
CREATE TABLE places (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'restaurant', 'museum', 'park'
    emoji VARCHAR(10) NOT NULL,
    
    -- Place Info (from PlaceInfo model)
    address TEXT, -- Can be NULL if coordinates are provided
    phone VARCHAR(50),
    website VARCHAR(255),
    email VARCHAR(255),
    opening_hours JSONB DEFAULT '{}', -- {"monday": "09:00-18:00"}
    highlights TEXT[] DEFAULT '{}',
    price_range VARCHAR(20),
    
    -- Location data (coordinates)
    latitude DECIMAL(10, 8), -- GPS latitude (can be NULL if address is provided)
    longitude DECIMAL(11, 8), -- GPS longitude (can be NULL if address is provided)
    
    -- Polymorphic data for different place types
    special_data JSONB DEFAULT '{}',
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint: Place must have either an address OR coordinates (or both)
    CONSTRAINT places_location_check CHECK (
        address IS NOT NULL OR (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
);

-- ================================
-- MENU_ITEMS TABLE (for restaurants)
-- ================================
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100) NOT NULL,
    allergens TEXT[] DEFAULT '{}',
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_vegan BOOLEAN DEFAULT FALSE,
    is_gluten_free BOOLEAN DEFAULT FALSE,
    image_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================
-- USER_PLACE_STATUS TABLE (Collection status per user)
-- ================================
CREATE TABLE user_place_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    is_visited BOOLEAN DEFAULT FALSE,
    last_visit TIMESTAMP WITH TIME ZONE,
    user_rating DECIMAL(2,1) CHECK (user_rating >= 1.0 AND user_rating <= 5.0),
    visit_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, place_id)
);

-- ================================
-- VISITS TABLE
-- ================================
CREATE TABLE visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    place_type VARCHAR(50) NOT NULL, -- 'restaurant', 'museum', etc.
    overall_rating DECIMAL(2,1) CHECK (overall_rating >= 1.0 AND overall_rating <= 5.0),
    notes TEXT,
    duration_minutes INTEGER,
    total_cost DECIMAL(10,2),
    metadata JSONB DEFAULT '{}', -- Place-specific visit data
    photo_urls TEXT[] DEFAULT '{}',
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================
-- VISIT_ACTIVITIES TABLE
-- ================================
CREATE TABLE visit_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'dish', 'exhibition', 'attraction'
    rating DECIMAL(2,1) CHECK (rating >= 1.0 AND rating <= 5.0),
    activity_data JSONB DEFAULT '{}', -- Type-specific data
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================
-- INDEXES FOR PERFORMANCE
-- ================================

-- Places indexes
CREATE INDEX idx_places_type ON places(type);
CREATE INDEX idx_places_name ON places USING gin(to_tsvector('english', name));
CREATE INDEX idx_places_address ON places USING gin(to_tsvector('english', address));
CREATE INDEX idx_places_special_data ON places USING gin(special_data);

-- Menu items indexes
CREATE INDEX idx_menu_items_place_id ON menu_items(place_id);
CREATE INDEX idx_menu_items_category ON menu_items(category);
CREATE INDEX idx_menu_items_dietary ON menu_items(is_vegetarian, is_vegan, is_gluten_free);

-- User place status indexes
CREATE INDEX idx_user_place_status_user_id ON user_place_status(user_id);
CREATE INDEX idx_user_place_status_place_id ON user_place_status(place_id);
CREATE INDEX idx_user_place_status_visited ON user_place_status(is_visited);

-- Visits indexes
CREATE INDEX idx_visits_user_id ON visits(user_id);
CREATE INDEX idx_visits_place_id ON visits(place_id);
CREATE INDEX idx_visits_date ON visits(date);
CREATE INDEX idx_visits_public ON visits(is_public);
CREATE INDEX idx_visits_metadata ON visits USING gin(metadata);

-- Visit activities indexes
CREATE INDEX idx_visit_activities_visit_id ON visit_activities(visit_id);
CREATE INDEX idx_visit_activities_type ON visit_activities(type);
CREATE INDEX idx_visit_activities_data ON visit_activities USING gin(activity_data);

-- ================================
-- TRIGGERS FOR updated_at
-- ================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_places_updated_at BEFORE UPDATE ON places
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON menu_items
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_user_place_status_updated_at BEFORE UPDATE ON user_place_status
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_visits_updated_at BEFORE UPDATE ON visits
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_visit_activities_updated_at BEFORE UPDATE ON visit_activities
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

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