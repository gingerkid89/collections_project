-- Add image support to the database
-- Add images table for flexible image storage and add image_url to places

BEGIN;

-- Add images table for storing multiple images per place
CREATE TABLE images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
    url VARCHAR(500) NOT NULL,
    caption TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    uploaded_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add primary image URL directly to places table for easy access
ALTER TABLE places ADD COLUMN image_url VARCHAR(500);

-- Index for performance
CREATE INDEX idx_images_place_id ON images(place_id);
CREATE INDEX idx_images_primary ON images(is_primary) WHERE is_primary = TRUE;

-- Trigger for images updated_at
CREATE TRIGGER update_images_updated_at BEFORE UPDATE ON images
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Add some sample images for existing places
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400' WHERE name = 'Spacca Napoli';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400' WHERE name = 'Via Roma';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400' WHERE name = 'Terra Rossa';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=400' WHERE name = 'Tuscolo Frankenbad';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=400' WHERE name = 'Tuscolo Münsterblick';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400' WHERE name = 'Restaurant Ruland';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=400' WHERE name = 'L''Osteria Bonn';

-- Museum images
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1459213599465-03ab6a4d5931?w=400' WHERE name = 'Beethoven-Haus Bonn';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=400' WHERE name = 'Haus der Geschichte';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400' WHERE name = 'Kunstmuseum Bonn';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400' WHERE name = 'Bundeskunsthalle';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=400' WHERE name = 'LVR-Landesmuseum Bonn';
UPDATE places SET image_url = 'https://images.unsplash.com/photo-1459213599465-03ab6a4d5931?w=400' WHERE name = 'Museum Koenig';

COMMIT;

-- Verify the updates
SELECT name, type, image_url FROM places WHERE image_url IS NOT NULL ORDER BY type, name;