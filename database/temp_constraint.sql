ALTER TABLE places ADD CONSTRAINT places_location_constraint 
CHECK (
    (address IS NOT NULL AND address != '') 
    OR 
    (latitude IS NOT NULL AND longitude IS NOT NULL)
);