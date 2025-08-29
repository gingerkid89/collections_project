-- Check which places might violate the constraint
SELECT 
    name, 
    CASE 
        WHEN address IS NOT NULL AND TRIM(address) != '' THEN 'has_address' 
        ELSE 'no_address' 
    END as addr_status,
    CASE 
        WHEN latitude IS NOT NULL AND longitude IS NOT NULL THEN 'has_coords' 
        ELSE 'no_coords' 
    END as coord_status,
    CASE 
        WHEN (address IS NOT NULL AND TRIM(address) != '') OR (latitude IS NOT NULL AND longitude IS NOT NULL) 
        THEN 'valid' 
        ELSE 'INVALID' 
    END as location_status
FROM places 
ORDER BY name;