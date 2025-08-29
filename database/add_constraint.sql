-- Add constraint to ensure either address or coordinates are present
ALTER TABLE places 
ADD CONSTRAINT places_must_have_location 
CHECK (
    (address IS NOT NULL AND TRIM(address) != '') 
    OR 
    (latitude IS NOT NULL AND longitude IS NOT NULL)
);

-- Test the constraint works
-- This should succeed (has address)
INSERT INTO places (name, type, emoji, address) 
VALUES ('Test Restaurant', 'restaurant', '🍽️', 'Test Street 123, Bonn');

-- This should succeed (has coordinates)  
INSERT INTO places (name, type, emoji, latitude, longitude) 
VALUES ('Test Museum', 'museum', '🏛️', 50.7374, 7.0982);

-- This should fail (has neither)
-- INSERT INTO places (name, type, emoji) VALUES ('Invalid Place', 'restaurant', '🍽️');

-- Clean up test records
DELETE FROM places WHERE name LIKE 'Test %';