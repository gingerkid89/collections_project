-- Migration: Add coordinates and address/location constraint
-- This ensures each place has either an address OR coordinates (or both)

BEGIN;

-- Add coordinate columns to places table
ALTER TABLE places 
    ADD COLUMN latitude DECIMAL(10, 8),
    ADD COLUMN longitude DECIMAL(11, 8);

-- Make address nullable (since we can now have coordinates instead)
ALTER TABLE places 
    ALTER COLUMN address DROP NOT NULL;

-- Add check constraint: must have either address or both coordinates
ALTER TABLE places 
    ADD CONSTRAINT places_location_constraint 
    CHECK (
        (address IS NOT NULL AND address != '') 
        OR 
        (latitude IS NOT NULL AND longitude IS NOT NULL)
    );

-- Add comment explaining the constraint
COMMENT ON CONSTRAINT places_location_constraint ON places IS 
    'Ensures each place has either a text address or GPS coordinates (latitude and longitude)';

-- Create index for coordinate-based queries (for future map functionality)
CREATE INDEX idx_places_coordinates ON places (latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Update existing places with approximate Bonn coordinates (for demonstration)
-- Note: In production, you'd want to geocode the actual addresses
UPDATE places SET 
    latitude = 50.7374 + (RANDOM() - 0.5) * 0.02, -- Bonn center ± ~1km
    longitude = 7.0982 + (RANDOM() - 0.5) * 0.02
WHERE latitude IS NULL;

COMMIT;