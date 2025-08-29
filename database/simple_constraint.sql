-- Simple constraint: either address or both coordinates must be present
ALTER TABLE places 
ADD CONSTRAINT places_location_required 
CHECK (address IS NOT NULL OR (latitude IS NOT NULL AND longitude IS NOT NULL));