-- Supabase Setup Script
-- Copy and run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Places table
CREATE TABLE places (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    emoji VARCHAR(10) NOT NULL,
    address TEXT,
    phone VARCHAR(50),
    website VARCHAR(255),
    email VARCHAR(255),
    opening_hours JSONB DEFAULT '{}',
    highlights TEXT[] DEFAULT '{}',
    price_range VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    image_url VARCHAR(500),
    special_data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Collections table
CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_emoji VARCHAR(10),
    color_hex VARCHAR(7),
    is_system_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Place-Collections junction table
CREATE TABLE place_collections (
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    PRIMARY KEY (place_id, collection_id)
);

-- Visits table
CREATE TABLE visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    place_type VARCHAR(50) NOT NULL,
    overall_rating DECIMAL(2,1) CHECK (overall_rating >= 1.0 AND overall_rating <= 5.0),
    notes TEXT,
    duration_minutes INTEGER,
    total_cost DECIMAL(10,2),
    metadata JSONB DEFAULT '{}',
    photo_urls TEXT[] DEFAULT '{}',
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Visit activities table
CREATE TABLE visit_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    rating DECIMAL(2,1) CHECK (rating >= 1.0 AND rating <= 5.0),
    activity_data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Menu items table
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    category VARCHAR(100),
    allergens TEXT[] DEFAULT '{}',
    is_vegetarian BOOLEAN DEFAULT false,
    is_vegan BOOLEAN DEFAULT false,
    is_gluten_free BOOLEAN DEFAULT false,
    image_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User place status table
CREATE TABLE user_place_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    is_visited BOOLEAN DEFAULT false,
    last_visit DATE,
    user_rating DECIMAL(2,1) CHECK (user_rating >= 1.0 AND user_rating <= 5.0),
    visit_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, place_id)
);

-- Exhibitions table
CREATE TABLE exhibitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    museum_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    exhibition_type VARCHAR(50) DEFAULT 'permanent',
    start_date DATE,
    end_date DATE,
    artist VARCHAR(255),
    period VARCHAR(100),
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    ticket_required BOOLEAN DEFAULT false,
    additional_cost DECIMAL(10,2) DEFAULT 0.00,
    image_url VARCHAR(500),
    website_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_places_type ON places(type);
CREATE INDEX idx_places_latitude_longitude ON places(latitude, longitude);
CREATE INDEX idx_visits_user_id ON visits(user_id);
CREATE INDEX idx_visits_place_id ON visits(place_id);
CREATE INDEX idx_visits_date ON visits(date);
CREATE INDEX idx_menu_items_place_id ON menu_items(place_id);
CREATE INDEX idx_exhibitions_museum_id ON exhibitions(museum_id);

-- Insert your user
INSERT INTO users (id, email, password_hash, display_name) 
VALUES ('ece71e81-a7a9-493a-89bd-eaa725a90a08', 'gingerkid89@gmail.com', 'hashed_password', 'Your Name')
ON CONFLICT (id) DO NOTHING;