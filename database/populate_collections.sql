-- Populate collections with existing places

-- Insert all restaurants into "All Restaurants" collection
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, 'c53bf10b-1fda-4289-9910-a1dc1948e2e8' 
FROM places p 
WHERE p.type = 'restaurant'
ON CONFLICT (place_id, collection_id) DO NOTHING;

-- Insert all museums into "All Museums" collection  
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, 'b5c5b6c9-b1ca-4053-b869-b1731028f179'
FROM places p
WHERE p.type = 'museum' 
ON CONFLICT (place_id, collection_id) DO NOTHING;

-- Insert Italian restaurants into "Italian Restaurants" collection
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, 'b12e91f0-ccba-47c6-91eb-ce1e9b55daf6'
FROM places p
WHERE p.type = 'restaurant'
  AND (p.special_data->>'cuisine' ILIKE '%italian%' OR p.name ILIKE '%italian%')
ON CONFLICT (place_id, collection_id) DO NOTHING;

-- Insert art museums into "Art Museums" collection
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, '2cdd6441-1856-4828-b468-bc4764495a04'
FROM places p
WHERE p.type = 'museum'
  AND (p.special_data->>'category' = 'art' 
       OR p.name ILIKE '%kunst%' 
       OR p.name ILIKE '%art%'
       OR p.name ILIKE '%macke%')
ON CONFLICT (place_id, collection_id) DO NOTHING;

-- Insert science/technology museums into "Science Museums" collection
INSERT INTO place_collections (place_id, collection_id)
SELECT p.id, 'b1f99e8e-e69a-4555-802b-5b81d2ac1124'
FROM places p
WHERE p.type = 'museum'
  AND (p.special_data->>'category' IN ('technology', 'science')
       OR p.name ILIKE '%techno%'
       OR p.name ILIKE '%science%'
       OR p.name ILIKE '%arithmeum%'
       OR p.name ILIKE '%deutsches%')
ON CONFLICT (place_id, collection_id) DO NOTHING;

-- Verify the population worked
SELECT 
  c.name as collection_name,
  COUNT(pc.place_id) as place_count,
  ARRAY_AGG(p.name ORDER BY p.name) as places
FROM collections c
LEFT JOIN place_collections pc ON c.id = pc.collection_id
LEFT JOIN places p ON pc.place_id = p.id
GROUP BY c.id, c.name
ORDER BY c.name;